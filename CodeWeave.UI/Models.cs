namespace CodeWeave.UI;

public class Node
{
    public string id { get; set; } = "";
    public string name { get; set; } = "";
    public string fullPath { get; set; } = "";
    public string language { get; set; } = "";
    public int lines { get; set; }
    public string folder { get; set; } = "";
    public int connections { get; set; }
}

public class Link
{
    public string source { get; set; } = "";
    public string target { get; set; } = "";
}

public class FolderGroup
{
    public string name { get; set; } = "";
    public int count { get; set; }
}