# CodeWeave Unit Tests

This project contains comprehensive unit tests for CodeWeave using xUnit.

## Test Coverage

### CodeWeaveEngineTests
Tests for the main code analysis engine:
- ✓ Basic HTML generation with C# files
- ✓ Exception handling for non-existent directories
- ✓ Exception handling for no supported files
- ✓ Support for all file extensions (.cs, .cpp, .h, .py)
- ✓ Cancellation token functionality
- ✓ Nested directory processing
- ✓ Valid JSON structure creation

### ScanProgressTests
Tests for progress tracking:
- ✓ Progress object creation
- ✓ Progress property updates

### ModelsTests
Tests for data models:
- ✓ Node model creation and properties
- ✓ Link model creation
- ✓ GraphData model with nodes and links
- ✓ Default values
- ✓ Various data formats and edge cases

## Running Tests

### Run all tests
```bash
cd /Users/sharrison/CodeWeave
dotnet test
```

### Run specific test class
```bash
dotnet test --filter ClassName=CodeWeaveEngineTests
```

### Run with code coverage
```bash
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
```

### Run tests with verbose output
```bash
dotnet test -v detailed
```

## Test Organization

- **CodeWeaveEngineTests**: Integration tests for the main engine
  - Uses temporary directories for file operations
  - Cleans up after each test with IAsyncLifetime
  - Tests both success and failure scenarios

- **ScanProgressTests**: Unit tests for progress tracking

- **ModelsTests**: Unit tests for data structures

## Adding New Tests

1. Create a new test class inheriting from base test class (if needed)
2. Use [Fact] for single tests or [Theory] with [InlineData] for parameterized tests
3. Follow AAA pattern: Arrange, Act, Assert
4. Use descriptive test names: `MethodName_Condition_ExpectedBehavior`

Example:
```csharp
[Fact]
public void GenerateAsync_WithValidInput_ReturnsValidOutput()
{
    // Arrange
    var input = "test";
    
    // Act
    var result = CodeWeaveEngine.DoSomething(input);
    
    // Assert
    Assert.NotNull(result);
}
```

## CI/CD Integration

Add to your GitHub Actions workflow:
```yaml
- name: Run tests
  run: dotnet test --verbosity normal --logger:"trx;LogFileName=test-results.trx"
  
- name: Upload test results
  uses: actions/upload-artifact@v3
  if: always()
  with:
    name: test-results
    path: '**/test-results.trx'
```

## Known Issues & Future Improvements

- [ ] Add performance benchmarks
- [ ] Add UI integration tests
- [ ] Add end-to-end tests with sample projects
- [ ] Add code coverage reports to CI/CD
