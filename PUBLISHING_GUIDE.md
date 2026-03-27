# CodeWeave Publishing Guide

This guide explains how to build, package, and distribute CodeWeave for macOS, Windows, and Linux.

## Quick Start

To publish and package for all platforms:

```bash
./publish-all.sh
```

This will create distributable packages in the `dist/` directory for all platforms.

## Platform-Specific Packaging

### macOS

```bash
./package-mac.sh
```

Creates:
- **CodeWeave.app** - Proper macOS application bundle with embedded icon
- **CodeWeave-*.dmg** - Disk image for distribution (if hdiutil is available)

Supports:
- Intel Macs (x64)
- Apple Silicon Macs (arm64)

**Distribution:**
Users can either:
1. Double-click the .dmg and drag to Applications
2. Unzip and move the .app to Applications folder

### Windows

```bash
./package-windows.sh
```

Creates:
- **CodeWeave-*-windows.zip** - Portable ZIP packages with executable
- **CodeWeaver.ico** - Icon included in package
- **README.txt** - Installation instructions

Supports:
- Windows x64
- Windows ARM64

**Distribution:**
Users extract the ZIP and run CodeWeave.UI.exe. No installation required (portable/standalone).

**Optional: MSI Installer**
For a more professional installation experience, you can use WiX Toolset:
1. Install WiX Toolset on Windows
2. Create a .wxs file in the project
3. Compile with: `candle.exe source.wxs && light.exe source.wixobj`

### Linux

```bash
./package-linux.sh
```

Creates:
- **codeweave-*-linux.tar.gz** - Tarball for manual installation
- **codeweave-*-*.deb** - Debian packages (if dpkg-deb is available)

Supports:
- Linux x64
- Linux ARM64 (Raspberry Pi, etc.)

**Distribution:**

**Tarball:**
```bash
tar xzf codeweave-VERSION-ARCH.tar.gz
sudo cp -r CodeWeave-ARCH /opt/codeweave
```

**Debian Package:**
```bash
sudo apt install ./codeweave_VERSION_ARCH.deb
```

## Output Structure

After running `publish-all.sh`, your `dist/` directory will contain:

```
dist/
├── mac/
│   ├── arm64/
│   │   ├── CodeWeave.app/          # Application bundle
│   │   └── CodeWeave-arm64.dmg     # DMG for distribution
│   └── x64/
│       ├── CodeWeave.app/
│       └── CodeWeave-x64.dmg
├── windows/
│   ├── x64/
│   │   └── CodeWeave-x64-windows.zip
│   └── arm64/
│       └── CodeWeave-arm64-windows.zip
└── linux/
    ├── x64/
    │   ├── CodeWeave-x64-linux.tar.gz
    │   └── codeweave-1.0.0-amd64.deb
    └── arm64/
        ├── CodeWeave-arm64-linux.tar.gz
        └── codeweave-1.0.0-arm64.deb
```

## Icons Used

The packaging scripts automatically include icons from `CodeWeave.UI/assets/`:

- **macOS**: `CodeWeaver.icns` - Native macOS icon format (embedded in .app bundles)
- **Windows**: `CodeWeaver.ico` - Windows icon format (included in packages)
- **Linux**: `CodeWeaver_512.png` - High-resolution PNG (used for desktop entries and icon themes)

## Customization

### Update Version Number

Edit the VERSION variables in the packaging scripts:

```bash
# In package-mac.sh, package-windows.sh, package-linux.sh
VERSION="1.0.0"  # Change this
```

Or use environment variables:
```bash
VERSION=2.0.0 ./publish-all.sh
```

### Update Bundle/Package Information

**macOS**:
Edit `BUNDLE_ID` in `package-mac.sh`:
```bash
BUNDLE_ID="com.yourcompany.codeweave"
```

**Linux**:
Edit maintainer in `package-linux.sh`:
```bash
Maintainer: Your Name <your@email.com>
```

### Custom Application Name

Edit `APP_NAME` variable in each script.

## Code Signing & Notarization

### macOS Code Signing

To code sign your app for distribution:

```bash
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" dist/mac/arm64/CodeWeave.app

# Verify the signature
spctl -a -v dist/mac/arm64/CodeWeave.app
```

### macOS Notarization (Required for distribution outside App Store)

```bash
# 1. Create a zip for notarization
ditto -c -k --sequesterRsrc dist/mac/arm64/CodeWeave.app CodeWeave.zip

# 2. Submit for notarization
xcrun notarytool submit CodeWeave.zip --apple-id your@email.com --password your-app-password --team-id YOUR_TEAM_ID

# 3. Wait for approval, then staple
xcrun stapler staple dist/mac/arm64/CodeWeave.app
```

### Windows Code Signing

To sign your Windows executable:

```bash
signtool.exe sign /f YourCertificate.pfx /p password /t http://timestamp.server.com dist/windows/x64/CodeWeave-x64/CodeWeave.UI.exe
```

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/publish.yml`:

```yaml
name: Publish Releases
on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      - run: bash ./publish-all.sh
      - uses: softprops/action-gh-release@v1
        with:
          files: dist/**/*
```

## Distribution Channels

### GitHub Releases
1. Create a release on GitHub
2. Upload the packaged files
3. Users can download directly

### Homebrew (macOS)
Create a formula to distribute via Homebrew.

### Chocolatey (Windows)
Create a Chocolatey package for easy installation.

### Snap (Linux)
Create a snap package for Ubuntu and other Linux distributions.

### AppImage (Linux)
Package as AppImage for universal Linux distribution.

## Testing Packages

Before distribution, test each package:

**macOS:**
```bash
# Extract and run
open dist/mac/arm64/CodeWeave.app
```

**Windows:**
```bash
# Extract and run
.\dist\windows\x64\CodeWeave-x64\CodeWeave.UI.exe
```

**Linux:**
```bash
# Test tarball
tar xzf dist/linux/x64/CodeWeave-x64-linux.tar.gz
./CodeWeave-x64/usr/bin/codeweave

# Test .deb
sudo apt install ./dist/linux/x64/codeweave-1.0.0-amd64.deb
codeweave
```

## Troubleshooting

### macOS .app not launching
- Verify Info.plist is valid XML
- Check executable permissions: `chmod +x CodeWeave.app/Contents/MacOS/CodeWeave`
- Check for code signature issues: `codesign -v CodeWeave.app`

### Windows executable not found
- Verify CodeWeave.UI.exe exists in the package
- Check antivirus isn't quarantining the executable
- Try running in compatibility mode for older Windows versions

### Linux desktop entry not showing
- Verify `.desktop` file syntax: `desktop-file-validate codecodeweave.desktop`
- Rebuild icon cache: `update-icon-caches /usr/share/icons/hicolor/`
- Check file permissions

## Release Checklist

- [ ] Update version numbers in scripts
- [ ] Update CHANGELOG
- [ ] Build and test all packages locally
- [ ] Run `./publish-all.sh`
- [ ] Test each package on target OS
- [ ] Create git tag: `git tag v1.0.0`
- [ ] Push tag: `git push origin v1.0.0`
- [ ] Create GitHub release
- [ ] Upload all packages
- [ ] Announce release on social media/forums
