#!/bin/bash

# CodeWeave macOS App Packager
# Creates proper .app bundles for macOS with embedded icons

set -e

PROJECT_PATH="CodeWeave.UI/CodeWeave.UI.csproj"
APP_NAME="CodeWeave"
BUNDLE_ID="com.codeweave.app"
VERSION="1.0.0"
OUTPUT_BASE="dist/mac"

echo "🍎 Packaging CodeWeave for macOS..."

# Function to create macOS .app bundle
package_macos() {
    local RID=$1
    local ARCH=$2
    local OUTPUT_DIR="$OUTPUT_BASE/$ARCH"
    
    echo "📦 Building macOS $ARCH..."
    mkdir -p "$OUTPUT_DIR"
    
    # Publish the app
    dotnet publish "$PROJECT_PATH" -c Release -r "$RID" -o "$OUTPUT_DIR/build"
    
    # Create .app bundle structure
    local APP_BUNDLE="$OUTPUT_DIR/$APP_NAME.app"
    local CONTENTS="$APP_BUNDLE/Contents"
    local MACOS_DIR="$CONTENTS/MacOS"
    local RESOURCES_DIR="$CONTENTS/Resources"
    
    mkdir -p "$MACOS_DIR"
    mkdir -p "$RESOURCES_DIR"
    
    # Move executable to MacOS directory
    mv "$OUTPUT_DIR/build/CodeWeave.UI" "$MACOS_DIR/$APP_NAME"
    chmod +x "$MACOS_DIR/$APP_NAME"
    
    # Copy other binaries and resources
    mv "$OUTPUT_DIR/build"/* "$CONTENTS/" 2>/dev/null || true
    
    # Copy icon
    cp "CodeWeave.UI/assets/CodeWeaver.icns" "$RESOURCES_DIR/"
    
    # Create Info.plist
    cat > "$CONTENTS/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleIconFile</key>
    <string>CodeWeaver.icns</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026. All rights reserved.</string>
    <key>NSRequiresIPhoneOS</key>
    <false/>
</dict>
</plist>
EOF
    
    # Clean up build directory
    rm -rf "$OUTPUT_DIR/build"
    
    # Create dmg (optional - requires hdiutil)
    echo "📦 Creating DMG for $ARCH..."
    hdiutil create -volname "$APP_NAME" -srcfolder "$APP_BUNDLE" -ov -format UDZO "$OUTPUT_DIR/$APP_NAME-$ARCH.dmg" 2>/dev/null || echo "⚠️  DMG creation skipped (hdiutil not available)"
    
    echo "✅ macOS $ARCH package complete: $APP_BUNDLE"
}

# Create output directory
mkdir -p "$OUTPUT_BASE"

# Package for both architectures
package_macos "osx-arm64" "arm64"
package_macos "osx-x64" "x64"

echo ""
echo "✅ macOS packaging complete!"
echo "📁 Packages are in: $OUTPUT_BASE"
echo ""
echo "To distribute:"
echo "  - Zip the .app bundle: zip -r CodeWeave-arm64.zip CodeWeave.app"
echo "  - Or use the .dmg file for a more polished distribution"
