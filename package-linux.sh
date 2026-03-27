#!/bin/bash

# CodeWeave Linux Packager
# Creates distributable packages for Linux

set -e

PROJECT_PATH="CodeWeave.UI/CodeWeave.UI.csproj"
APP_NAME="codeweave"
APP_NAME_DISPLAY="CodeWeave"
VERSION="1.0.0"
OUTPUT_BASE="dist/linux"

echo "🐧 Packaging CodeWeave for Linux..."

# Function to package Linux build
package_linux() {
    local RID=$1
    local ARCH=$2
    local OUTPUT_DIR="$OUTPUT_BASE/$ARCH"
    
    echo "📦 Building Linux $ARCH..."
    mkdir -p "$OUTPUT_DIR"
    
    # Publish the app
    dotnet publish "$PROJECT_PATH" -c Release -r "$RID" -o "$OUTPUT_DIR/build"
    
    # Create FHS-compliant directory structure
    local PREFIX="$OUTPUT_DIR/$APP_NAME_DISPLAY-$ARCH"
    mkdir -p "$PREFIX/opt/$APP_NAME"
    mkdir -p "$PREFIX/usr/bin"
    mkdir -p "$PREFIX/usr/share/applications"
    mkdir -p "$PREFIX/usr/share/icons/hicolor/512x512/apps"
    mkdir -p "$PREFIX/DEBIAN"
    
    # Copy application files
    mv "$OUTPUT_DIR/build"/* "$PREFIX/opt/$APP_NAME/" 2>/dev/null || true
    chmod +x "$PREFIX/opt/$APP_NAME/CodeWeave.UI"
    
    # Copy largest icon
    cp "CodeWeave.UI/assets/CodeWeaver_512.png" "$PREFIX/usr/share/icons/hicolor/512x512/apps/$APP_NAME.png"
    
    # Create desktop entry
    cat > "$PREFIX/usr/share/applications/$APP_NAME.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=CodeWeave
Comment=Interactive code map generator
Exec=/opt/codeweave/CodeWeave.UI
Icon=codeweave
Terminal=false
Categories=Development;Utility;
EOF
    
    # Create launcher script
    cat > "$PREFIX/usr/bin/$APP_NAME" << 'EOF'
#!/bin/bash
exec /opt/codeweave/CodeWeave.UI "$@"
EOF
    chmod +x "$PREFIX/usr/bin/$APP_NAME"
    
    # Create control file for dpkg
    local ARCH_DEB="amd64"
    [[ "$ARCH" == "arm64" ]] && ARCH_DEB="arm64"
    
    cat > "$PREFIX/DEBIAN/control" << EOF
Package: codeweave
Version: $VERSION
Architecture: $ARCH_DEB
Maintainer: CodeWeave Team <info@codeweave.dev>
Description: Interactive code map generator
 Generate interactive code maps from your projects.
 Supports drag-and-drop folder selection and HTML-based visualization.
Depends: libssl3
Homepage: https://github.com/yourusername/CodeWeave
EOF
    
    # Create postinst script
    cat > "$PREFIX/DEBIAN/postinst" << 'EOF'
#!/bin/bash
update-desktop-database || true
EOF
    chmod +x "$PREFIX/DEBIAN/postinst"
    
    # Create README
    cat > "$PREFIX/README.md" << 'EOF'
# CodeWeave

Interactive code map generator.

## Installation

### From source tarball:
1. Extract: `tar xzf codeweave-VERSION-ARCH.tar.gz`
2. Copy to system: `sudo cp -r CodeWeave-ARCH /opt/codeweave`
3. Run: `codeweave`

### From .deb package:
```bash
sudo apt install ./codeweave_VERSION_ARCH.deb
codeweave
```

## System Requirements
- Glibc 2.31+ (Ubuntu 20.04+, Debian 11+)
- GTK 3.0+ or Wayland compatible environment
- No additional dependencies required

## Uninstall
```bash
sudo apt remove codeweave
```

## Building from source
See the BUILD_GUIDE.md for development instructions.
EOF
    
    # Create tarball
    echo "📦 Creating tarball for $ARCH..."
    cd "$OUTPUT_BASE"
    tar czf "$APP_NAME_DISPLAY-$ARCH-linux.tar.gz" "$ARCH/$APP_NAME_DISPLAY-$ARCH"
    
    # Create .deb package
    echo "📦 Creating .deb package for $ARCH..."
    dpkg-deb --build "$ARCH/$APP_NAME_DISPLAY-$ARCH" "$APP_NAME-$VERSION-$ARCH.deb" 2>/dev/null || echo "⚠️  .deb creation requires dpkg tools"
    
    cd - > /dev/null
    
    # Clean up build directory
    rm -rf "$OUTPUT_DIR/build"
    
    echo "✅ Linux $ARCH package complete"
}

# Create output directory
mkdir -p "$OUTPUT_BASE"

# Package for both architectures
package_linux "linux-x64" "x64"
package_linux "linux-arm64" "arm64"

echo ""
echo "✅ Linux packaging complete!"
echo "📁 Packages are in: $OUTPUT_BASE"
echo ""
echo "Distributions ready:"
ls -lh "$OUTPUT_BASE"/*.tar.gz "$OUTPUT_BASE"/*.deb 2>/dev/null || echo "Packages created in $OUTPUT_BASE"
