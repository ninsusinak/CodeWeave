using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace CodeWeave.UI;

public static class CodeWeaveEngine
{
    private static readonly string[] SupportedExtensions = [".cs", ".cpp", ".h", ".py"];

    public static async Task<string> GenerateAsync(
        string rootPath,
        string templatePath,
        string outputPath,
        IProgress<ScanProgress>? progress = null,
        CancellationToken cancellationToken = default)
    {
        if (!Directory.Exists(rootPath))
            throw new DirectoryNotFoundException(rootPath);

        Report(progress, "Finding supported files...", 0, 1);

        var files = Directory
            .GetFiles(rootPath, "*.*", SearchOption.AllDirectories)
            .Where(IsSupportedFile)
            .Where(f => !IsIgnoredPath(f))
            .OrderBy(f => f)
            .ToList();

        if (files.Count == 0)
            throw new InvalidOperationException("No supported source files were found.");

        var nodes = new List<Node>();
        var links = new List<Link>();
        var fileLookup = BuildFileLookup(files);

        Report(progress, $"Found {files.Count} files. Scanning...", 0, files.Count);

        for (int i = 0; i < files.Count; i++)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var file = files[i];

            string content;
            try
            {
                content = await File.ReadAllTextAsync(file, cancellationToken);
            }
            catch
            {
                Report(progress, $"Skipping unreadable file: {Path.GetFileName(file)}", i + 1, files.Count);
                continue;
            }

            var relativePath = Path.GetRelativePath(rootPath, file).Replace('\\', '/');

            nodes.Add(new Node
            {
                id = relativePath,
                name = Path.GetFileName(file),
                fullPath = relativePath,
                language = GetLanguage(file),
                lines = CountLines(content),
                folder = NormalizeFolder(Path.GetDirectoryName(relativePath))
            });

            var imports = ExtractImports(content, file);

            foreach (var import in imports)
            {
                var resolved = ResolveImport(import, file, rootPath, fileLookup);
                if (resolved is null)
                    continue;

                var targetId = Path.GetRelativePath(rootPath, resolved).Replace('\\', '/');

                if (relativePath != targetId &&
                    !links.Any(l => l.source == relativePath && l.target == targetId))
                {
                    links.Add(new Link
                    {
                        source = relativePath,
                        target = targetId
                    });
                }
            }

            Report(progress, $"Scanning {Path.GetFileName(file)}", i + 1, files.Count);
        }

        ApplyConnectionCounts(nodes, links);

        var folderGroups = nodes
            .GroupBy(n => n.folder)
            .Select(g => new FolderGroup
            {
                name = g.Key,
                count = g.Count()
            })
            .OrderByDescending(g => g.count)
            .ThenBy(g => g.name)
            .ToList();

        var topConnected = nodes
            .OrderByDescending(n => n.connections)
            .ThenBy(n => n.name)
            .Take(10)
            .Select(n => new
            {
                name = n.name,
                path = n.fullPath,
                connections = n.connections,
                language = n.language
            })
            .ToList();

        var graph = new
        {
            nodes,
            links,
            folderGroups,
            topConnected,
            generatedAt = DateTimeOffset.Now.ToString("u"),
            fileCount = nodes.Count,
            linkCount = links.Count
        };

        Report(progress, "Generating HTML...", files.Count, files.Count);

        var json = JsonSerializer.Serialize(graph);

        var template = await File.ReadAllTextAsync(templatePath, cancellationToken);
        var outputHtml = template.Replace("__GRAPH_DATA__", json);

        await File.WriteAllTextAsync(outputPath, outputHtml, cancellationToken);

        Report(progress, "Done.", files.Count, files.Count);

        return outputPath;
    }

    private static void ApplyConnectionCounts(List<Node> nodes, List<Link> links)
    {
        var counts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

        foreach (var link in links)
        {
            counts.TryGetValue(link.source, out var sourceCount);
            counts[link.source] = sourceCount + 1;

            counts.TryGetValue(link.target, out var targetCount);
            counts[link.target] = targetCount + 1;
        }

        foreach (var node in nodes)
        {
            counts.TryGetValue(node.id, out var count);
            node.connections = count;
        }
    }

    private static void Report(IProgress<ScanProgress>? progress, string message, int current, int total)
    {
        progress?.Report(new ScanProgress
        {
            Message = message,
            Current = current,
            Total = total
        });
    }

    private static bool IsSupportedFile(string path) =>
        SupportedExtensions.Contains(Path.GetExtension(path), StringComparer.OrdinalIgnoreCase);

    private static bool IsIgnoredPath(string path)
    {
        var normalized = path.Replace('\\', '/').ToLowerInvariant();

        return normalized.Contains("/bin/")
            || normalized.Contains("/obj/")
            || normalized.Contains("/.git/")
            || normalized.Contains("/node_modules/")
            || normalized.Contains("/dist/")
            || normalized.Contains("/build/")
            || normalized.Contains("/packages/")
            || normalized.Contains("/venv/")
            || normalized.Contains("/.venv/");
    }

    private static string GetLanguage(string path) =>
        Path.GetExtension(path).ToLowerInvariant() switch
        {
            ".cs" => "csharp",
            ".cpp" => "cpp",
            ".h" => "cpp",
            ".py" => "python",
            _ => "other"
        };

    private static int CountLines(string content) =>
        string.IsNullOrEmpty(content) ? 0 : content.Split('\n').Length;

    private static string NormalizeFolder(string? folder)
    {
        if (string.IsNullOrWhiteSpace(folder))
            return "/";

        return folder.Replace('\\', '/');
    }

    private static Dictionary<string, List<string>> BuildFileLookup(List<string> files)
    {
        var lookup = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);

        foreach (var file in files)
        {
            var nameWithoutExtension = Path.GetFileNameWithoutExtension(file);

            if (!lookup.TryGetValue(nameWithoutExtension, out var list))
            {
                list = [];
                lookup[nameWithoutExtension] = list;
            }

            list.Add(file);

            var fileNameWithExtension = Path.GetFileName(file);
            if (!lookup.TryGetValue(fileNameWithExtension, out var listWithExtension))
            {
                listWithExtension = [];
                lookup[fileNameWithExtension] = listWithExtension;
            }

            listWithExtension.Add(file);
        }

        return lookup;
    }

    private static List<string> ExtractImports(string content, string filePath)
    {
        var ext = Path.GetExtension(filePath).ToLowerInvariant();
        var imports = new List<string>();

        switch (ext)
        {
            case ".cs":
                imports.AddRange(ExtractMatches(content, @"using\s+([\w\.]+)\s*;"));
                break;

            case ".cpp":
            case ".h":
                imports.AddRange(ExtractMatches(content, "#include\\s+[\"<]([^\">]+)[\">]"));
                break;

            case ".py":
                imports.AddRange(ExtractMatches(content, @"^\s*import\s+([\w\.]+)", RegexOptions.Multiline));
                imports.AddRange(ExtractMatches(content, @"^\s*from\s+([\w\.]+)\s+import\s+", RegexOptions.Multiline));
                break;
        }

        return imports
            .Select(x => x.Trim())
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private static List<string> ExtractMatches(string content, string pattern, RegexOptions options = RegexOptions.None)
    {
        return Regex.Matches(content, pattern, options)
            .Select(m => m.Groups[1].Value)
            .Where(v => !string.IsNullOrWhiteSpace(v))
            .ToList();
    }

    private static string? ResolveImport(
        string import,
        string currentFile,
        string rootPath,
        Dictionary<string, List<string>> fileLookup)
    {
        var ext = Path.GetExtension(currentFile).ToLowerInvariant();

        if (ext is ".cpp" or ".h")
        {
            if (fileLookup.TryGetValue(import, out var exactIncludeMatches))
                return PreferClosest(currentFile, exactIncludeMatches);

            var includeName = Path.GetFileNameWithoutExtension(import);
            if (fileLookup.TryGetValue(includeName, out var includeMatches))
                return PreferClosest(currentFile, includeMatches);

            var directPath = Path.GetFullPath(Path.Combine(Path.GetDirectoryName(currentFile) ?? rootPath, import));
            if (File.Exists(directPath) && IsSupportedFile(directPath))
                return directPath;
        }

        if (ext == ".py")
        {
            var moduleName = import.Split('.').Last();
            if (fileLookup.TryGetValue(moduleName, out var pyMatches))
                return PreferClosest(currentFile, pyMatches);
        }

        if (ext == ".cs")
        {
            var namespaceTail = import.Split('.').Last();
            if (fileLookup.TryGetValue(namespaceTail, out var csMatches))
                return PreferClosest(currentFile, csMatches);
        }

        return null;
    }

    private static string? PreferClosest(string currentFile, List<string> candidates)
    {
        if (candidates.Count == 0)
            return null;

        if (candidates.Count == 1)
            return candidates[0];

        var currentDir = Path.GetDirectoryName(currentFile) ?? "";

        return candidates
            .OrderBy(c => Path.GetDirectoryName(c)?.StartsWith(currentDir, StringComparison.OrdinalIgnoreCase) == true ? 0 : 1)
            .ThenBy(c => c.Length)
            .First();
    }
}