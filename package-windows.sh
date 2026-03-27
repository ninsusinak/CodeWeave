#!/bin/bash

# CodeWeave Windows Packager
# Creates installer-ready packages for Windows

set -e

PROJECT_PATH="CodeWeave.UI/CodeWeave.UI.csproj"
APP_NAME="CodeWeave"
VERSION="1.0.0"
OUTPUT_BASE="dist/windows"

echo "🪟 Packaging CodeWeave for Windows..."

# Function to package Windows build
package_windows() {
    local RID=$1
    local ARCH=$2
    local OUTPUT_DIR="$OUTPUT_BASE/$ARCH"
    
    echo "📦 Building Windows $ARCH..."
    mkdir -p "$OUTPUT_DIR"
    
    # Publish the app
    dotnet publish "$PROJECT_PATH" -c Release -r "$RID" -o "$OUTPUT_DIR/build"
    
    # Create a clean package directory
    local PACKAGE_DIR="$OUTPUT_DIR/$APP_NAME-$ARCH"
    mkdir -p "$PACKAGE_DIR"
    
    # Copy all files
    mv "$OUTPUT_DIR/build"/* "$PACKAGE_DIR/" 2>/dev/null || true
    
    # Copy icons to package
    cp "CodeWeave.UI/assets/CodeWeaver.ico" "$PACKAGE_DIR/"
    
    # Create a README for the package
    cat > "$PACKAGE_DIR/README.txt" << 'EOF'
CodeWeave
=========

Installation:
1. Extract this folder to your desired location
2. Run CodeWeave.UI.exe

System Requirements:
- Windows 10 or later
- No additional dependencies required (.NET runtime is included)

To uninstall:
Simply delete the folder.

For more information, visit: https://github.com/yourusername/CodeWeave
EOF
    
    # Clean up build directory
    rm -rf "$OUTPUT_DIR/build"
    
    # Create a zip archive
    echo "📦 Creating archive for $ARCH..."
    cd "$OUTPUT_BASE"
    zip -r -q "$APP_NAME-$ARCH-windows.zip" "$ARCH/$APP_NAME-$ARCH"
    cd - > /dev/null
    
    echo "✅ Windows $ARCH package complete: $PACKAGE_DIR"
}

# Create output directory
mkdir -p "$OUTPUT_BASE"

# Package for both architectures
package_windows "win-x64" "x64"
package_windows "win-arm64" "arm64"

echo ""
echo "✅ Windows packaging complete!"
echo "📁 Packages are in: $OUTPUT_BASE"
echo ""
echo "Distributions ready:"
ls -lh "$OUTPUT_BASE"/*.zip 2>/dev/null || echo "Archives created in $OUTPUT_BASE"
