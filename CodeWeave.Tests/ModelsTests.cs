using Xunit;
using CodeWeave.UI;

namespace CodeWeave.Tests;

public class ModelsTests
{
    [Fact]
    public void Node_CanBeCreatedWithAllProperties()
    {
        // Act
        var node = new Node
        {
            id = "test-id",
            name = "TestNode",
            folder = "src",
            fullPath = "/src/test.cs",
            language = "csharp",
            lines = 1500,
            connections = 3
        };

        // Assert
        Assert.Equal("test-id", node.id);
        Assert.Equal("TestNode", node.name);
        Assert.Equal("src", node.folder);
        Assert.Equal("/src/test.cs", node.fullPath);
        Assert.Equal("csharp", node.language);
        Assert.Equal(1500, node.lines);
        Assert.Equal(3, node.connections);
    }

    [Fact]
    public void Link_CanBeCreatedWithSourceAndTarget()
    {
        // Act
        var link = new Link
        {
            source = "file1.cs",
            target = "file2.cs"
        };

        // Assert
        Assert.Equal("file1.cs", link.source);
        Assert.Equal("file2.cs", link.target);
    }

    [Fact]
    public void FolderGroup_CanBeCreatedWithNameAndCount()
    {
        // Act
        var folderGroup = new FolderGroup
        {
            name = "src",
            count = 5
        };

        // Assert
        Assert.Equal("src", folderGroup.name);
        Assert.Equal(5, folderGroup.count);
    }

    [Fact]
    public void Node_DefaultValues()
    {
        // Act
        var node = new Node();

        // Assert
        Assert.Equal("", node.id);
        Assert.Equal("", node.name);
        Assert.Equal("", node.folder);
        Assert.Equal("", node.fullPath);
        Assert.Equal("", node.language);
        Assert.Equal(0, node.lines);
        Assert.Equal(0, node.connections);
    }

    [Fact]
    public void Link_DefaultValues()
    {
        // Act
        var link = new Link();

        // Assert
        Assert.Equal("", link.source);
        Assert.Equal("", link.target);
    }

    [Theory]
    [InlineData("MyClass", "MyClass")]
    [InlineData("my_variable", "my_variable")]
    [InlineData("CONSTANT", "CONSTANT")]
    [InlineData("file.cs", "file.cs")]
    public void Node_CanHaveVariousNameFormats(string name, string expectedName)
    {
        // Act
        var node = new Node { name = name };

        // Assert
        Assert.Equal(expectedName, node.name);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(100)]
    [InlineData(1000000)]
    public void Node_LinesCanBeAnyInteger(int lines)
    {
        // Act
        var node = new Node { lines = lines };

        // Assert
        Assert.Equal(lines, node.lines);
    }

    [Theory]
    [InlineData("csharp")]
    [InlineData("cpp")]
    [InlineData("python")]
    [InlineData("c")]
    public void Node_CanHaveVariousLanguages(string language)
    {
        // Act
        var node = new Node { language = language };

        // Assert
        Assert.Equal(language, node.language);
    }

    [Fact]
    public void Node_ConnectionsStartAtZero()
    {
        // Act
        var node = new Node();

        // Assert
        Assert.Equal(0, node.connections);
    }

    [Fact]
    public void FolderGroup_CanTrackMultipleFiles()
    {
        // Arrange
        var folderGroups = new[]
        {
            new FolderGroup { name = "src", count = 10 },
            new FolderGroup { name = "tests", count = 5 }
        };

        // Assert
        Assert.Equal(2, folderGroups.Length);
        Assert.Equal("src", folderGroups[0].name);
        Assert.Equal(10, folderGroups[0].count);
        Assert.Equal("tests", folderGroups[1].name);
        Assert.Equal(5, folderGroups[1].count);
    }

    [Fact]
    public void Link_CanConnectDifferentFileTypes()
    {
        // Act
        var links = new[]
        {
            new Link { source = "file1.cs", target = "file2.cpp" },
            new Link { source = "file2.cpp", target = "file3.h" }
        };

        // Assert
        Assert.Equal(2, links.Length);
        Assert.Equal("file1.cs", links[0].source);
        Assert.Equal("file2.cpp", links[0].target);
    }
}
