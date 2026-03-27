using Avalonia.Controls;
using Avalonia.Input;
using Avalonia.Interactivity;
using Avalonia.Platform.Storage;
using System.Diagnostics;

namespace CodeWeave.UI;

public partial class MainWindow : Window
{
    private string? _selectedFolder;
    private string? _lastOutputPath;
    private CancellationTokenSource? _scanCts;

    public MainWindow()
    {
        InitializeComponent();

        AddHandler(DragDrop.DragOverEvent, DragOverHandler);
        AddHandler(DragDrop.DragEnterEvent, DragEnterHandler);
        AddHandler(DragDrop.DragLeaveEvent, DragLeaveHandler);
        AddHandler(DragDrop.DropEvent, DropHandler);

        DragDrop.SetAllowDrop(this, true);
        
        // Icon is set via .csproj AppleIconAsset/ApplicationIcon properties
    }

    private void DragEnterHandler(object? sender, DragEventArgs e)
    {
#pragma warning disable CS0618
        if (e.Data.Contains(DataFormats.Files))
        {
            DropZone.BorderBrush = Avalonia.Media.Brush.Parse("#7AA2FF");
            DropZone.Background = Avalonia.Media.Brush.Parse("#162142");
            DropTitle.Text = "Release to select folder";
        }
#pragma warning restore CS0618
    }

    private void DragLeaveHandler(object? sender, RoutedEventArgs e)
    {
        ResetDropZoneVisual();
    }

    private void DragOverHandler(object? sender, DragEventArgs e)
    {
#pragma warning disable CS0618
        if (e.Data.Contains(DataFormats.Files))
            e.DragEffects = DragDropEffects.Copy;
        else
            e.DragEffects = DragDropEffects.None;
#pragma warning restore CS0618

        e.Handled = true;
    }

    private void DropHandler(object? sender, DragEventArgs e)
    {
        try
        {
#pragma warning disable CS0618
            if (!e.Data.Contains(DataFormats.Files))
            {
                ResetDropZoneVisual();
                return;
            }

            var files = e.Data.GetFiles();
            var first = files?.FirstOrDefault();

            if (first is null)
            {
                ResetDropZoneVisual();
                return;
            }

            var path = first.TryGetLocalPath();
            if (path is null)
            {
                ResetDropZoneVisual();
                return;
            }

            if (Directory.Exists(path))
            {
                SetSelectedFolder(path);
                StatusText.Text = $"Folder selected: {path}";
            }
            else
            {
                StatusText.Text = "Please drop a folder, not a file.";
            }
#pragma warning restore CS0618
        }
        catch (Exception ex)
        {
            StatusText.Text = $"Drop failed: {ex.Message}";
        }
        finally
        {
            ResetDropZoneVisual();
        }
    }

    private async void BrowseButton_OnClick(object? sender, RoutedEventArgs e)
    {
        var folders = await StorageProvider.OpenFolderPickerAsync(new FolderPickerOpenOptions
        {
            Title = "Choose a project folder",
            AllowMultiple = false
        });

        var folder = folders.FirstOrDefault();
        if (folder is null)
            return;

        var path = folder.TryGetLocalPath();
        if (path is null)
        {
            StatusText.Text = "Could not resolve local folder path.";
            return;
        }

        SetSelectedFolder(path);
        StatusText.Text = $"Folder selected: {path}";
    }

    private async void ScanButton_OnClick(object? sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(_selectedFolder))
            return;

        _scanCts?.Cancel();
        _scanCts = new CancellationTokenSource();

        try
        {
            SetBusyState(true);

            var templatePath = Path.Combine(AppContext.BaseDirectory, "template.html");
            var outputPath = Path.Combine(_selectedFolder, "output.html");

            var progress = new Progress<ScanProgress>(p =>
            {
                ProgressText.Text = p.Message;
                ScanProgressBar.Value = p.Percent;
                StatusText.Text = $"{p.Message} ({p.Current}/{p.Total})";
            });

            _lastOutputPath = await CodeWeaveEngine.GenerateAsync(
                _selectedFolder,
                templatePath,
                outputPath,
                progress,
                _scanCts.Token);

            ProgressText.Text = "Scan complete.";
            ScanProgressBar.Value = 100;
            StatusText.Text = $"Done. Generated: {_lastOutputPath}";
            OpenOutputButton.IsEnabled = File.Exists(_lastOutputPath);
        }
        catch (OperationCanceledException)
        {
            StatusText.Text = "Scan cancelled.";
            ProgressText.Text = "Cancelled.";
        }
        catch (Exception ex)
        {
            StatusText.Text = $"Scan failed: {ex.Message}";
            ProgressText.Text = "Scan failed.";
        }
        finally
        {
            SetBusyState(false);
        }
    }

    private void OpenOutputButton_OnClick(object? sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(_lastOutputPath) || !File.Exists(_lastOutputPath))
            return;

        Process.Start(new ProcessStartInfo
        {
            FileName = _lastOutputPath,
            UseShellExecute = true
        });
    }

    private void SetSelectedFolder(string path)
    {
        _selectedFolder = path;
        FolderPathText.Text = path;
        DropTitle.Text = "Folder ready";
        ScanButton.IsEnabled = true;
        OpenOutputButton.IsEnabled = false;
        ScanProgressBar.Value = 0;
        ProgressText.Text = "Ready to scan.";
    }

    private void SetBusyState(bool isBusy)
    {
        BrowseButton.IsEnabled = !isBusy;
        ScanButton.IsEnabled = !isBusy && !string.IsNullOrWhiteSpace(_selectedFolder);
        OpenOutputButton.IsEnabled = !isBusy && !string.IsNullOrWhiteSpace(_lastOutputPath) && File.Exists(_lastOutputPath);

        DropTitle.Text = isBusy ? "Scanning project..." : (!string.IsNullOrWhiteSpace(_selectedFolder) ? "Folder ready" : "Drop folder here");
    }

    private void ResetDropZoneVisual()
    {
        DropZone.BorderBrush = Avalonia.Media.Brush.Parse("#4C6FFF");
        DropZone.Background = Avalonia.Media.Brush.Parse("#10162B");

        if (string.IsNullOrWhiteSpace(_selectedFolder))
            DropTitle.Text = "Drop folder here";
        else
            DropTitle.Text = "Folder ready";
    }
}