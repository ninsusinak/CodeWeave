using System;
using System.IO;
using System.Threading.Tasks;

async Task Main()
{
    var templatePath = "/Users/sharrison/CodeWeave/CodeWeave.UI/Template.html";
    if (File.Exists(templatePath))
    {
        var content = await File.ReadAllTextAsync(templatePath);
        Console.WriteLine($"Template size: {content.Length} bytes");
        Console.WriteLine($"Contains __GRAPH_DATA__: {content.Contains("__GRAPH_DATA__")}");
        // Print first 500 chars
        Console.WriteLine(content.Substring(0, Math.Min(500, content.Length)));
    }
    else
    {
        Console.WriteLine("Template not found");
    }
}

await Main();
