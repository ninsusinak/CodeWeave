namespace CodeWeave.UI;

public class ScanProgress
{
    public string Message { get; set; } = "";
    public int Current { get; set; }
    public int Total { get; set; }
    public double Percent => Total <= 0 ? 0 : (double)Current / Total * 100.0;
}