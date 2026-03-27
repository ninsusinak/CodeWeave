# CodeWeave - Cross-Platform Build Guide

Your project is now configured to build for macOS, Windows, and Linux across multiple architectures.

## Supported Platforms

- **Windows**: x64, ARM64
- **macOS**: x64 (Intel), ARM64 (Apple Silicon)
- **Linux**: x64, ARM64

## Building for All Platforms

### On macOS/Linux:
```bash
./build-all.sh
```

### On Windows:
```bash
build-all.bat
```

This will create a `dist` directory with subdirectories for each platform:
- `dist/win-x64` - Windows 64-bit
- `dist/win-arm64` - Windows ARM64
- `dist/mac-x64` - macOS Intel
- `dist/mac-arm64` - macOS Apple Silicon
- `dist/linux-x64` - Linux 64-bit
- `dist/linux-arm64` - Linux ARM64

## Building for a Specific Platform

To publish for a single platform, use:

```bash
dotnet publish CodeWeave.UI/CodeWeave.UI.csproj -c Release -r <runtime-id> -o <output-path>
```

Replace `<runtime-id>` with one of: `win-x64`, `win-arm64`, `osx-x64`, `osx-arm64`, `linux-x64`, `linux-arm64`

Example:
```bash
dotnet publish CodeWeave.UI/CodeWeave.UI.csproj -c Release -r osx-arm64 -o dist/mac-arm64
```

## Runtime Identifiers (RIDs)

- `win-x64` - Windows 64-bit
- `win-arm64` - Windows ARM64 (ARM-based Windows devices)
- `osx-x64` - macOS x64 (Intel)
- `osx-arm64` - macOS ARM64 (Apple Silicon M1/M2/M3 chips)
- `linux-x64` - Linux x64
- `linux-arm64` - Linux ARM64 (Raspberry Pi, etc.)

## Current Configuration

The project is configured with:
- **PublishSingleFile**: Bundles the entire app into a single executable
- **SelfContained**: Includes the .NET runtime with the application
- **PublishTrimmed**: Disabled (set to false) to ensure full compatibility

## Notes for macOS App Distribution

To create a proper macOS app bundle (.app) for distribution, you may need to:
1. Create an app bundle structure after publishing
2. Use the `osx-arm64` RID for Apple Silicon Macs
3. Use the `osx-x64` RID for Intel Macs
4. Code sign and notarize the app for distribution outside the App Store

## Running Locally

To run the app for your current platform:
```bash
dotnet run --project CodeWeave.UI/CodeWeave.UI.csproj
```
