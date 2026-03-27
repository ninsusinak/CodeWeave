#!/bin/bash

# CodeWeave Universal Publisher
# Publishes and packages the app for all platforms

set -e

echo "🚀 CodeWeave Universal Publisher"
echo "=================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if dotnet is installed
if ! command -v dotnet &> /dev/null; then
    echo "❌ Error: dotnet is not installed or not in PATH"
    exit 1
fi

echo "📋 Starting publication process..."
echo ""

# Create main dist directory
mkdir -p dist

# Detect OS and run scripts
OS="$(uname -s)"

echo "Step 1️⃣ : Packaging for macOS..."
if command -v bash &> /dev/null; then
    bash ./package-mac.sh
else
    echo "⚠️  Skipping macOS packaging"
fi
echo ""

echo "Step 2️⃣ : Packaging for Windows..."
bash ./package-windows.sh
echo ""

echo "Step 3️⃣ : Packaging for Linux..."
bash ./package-linux.sh
echo ""

# Create summary
echo "╔════════════════════════════════════════╗"
echo "║  ✅ Publishing Complete!               ║"
echo "╚════════════════════════════════════════╝"
echo ""

echo "📦 Distribution Packages:"
echo ""

if [ -d "dist/mac" ]; then
    echo "🍎 macOS:"
    find dist/mac -name "*.app" -type d 2>/dev/null | while read app; do
        echo "   ✓ $(basename "$app")"
    done
    find dist/mac -name "*.dmg" 2>/dev/null | while read dmg; do
        echo "   ✓ $(basename "$dmg")"
    done
fi

if [ -d "dist/windows" ]; then
    echo ""
    echo "🪟 Windows:"
    find dist/windows -name "*.zip" 2>/dev/null | while read zip; do
        echo "   ✓ $(basename "$zip")"
    done
fi

if [ -d "dist/linux" ]; then
    echo ""
    echo "🐧 Linux:"
    find dist/linux -name "*.tar.gz" 2>/dev/null | while read tar; do
        echo "   ✓ $(basename "$tar")"
    done
    find dist/linux -name "*.deb" 2>/dev/null | while read deb; do
        echo "   ✓ $(basename "$deb")"
    done
fi

echo ""
echo "📊 Distribution Summary:"
echo "   macOS:   2 architectures (Intel x64, Apple Silicon arm64)"
echo "   Windows: 2 architectures (x64, ARM64)"
echo "   Linux:   2 architectures (x64, ARM64)"
echo ""
echo "🎯 Total: 6 platform/architecture combinations"
echo ""
echo "📂 Output directory: dist/"
echo ""
echo "Next steps:"
echo "  1. Test each package on target platform"
echo "  2. Create version tags: git tag v1.0.0"
echo "  3. Upload to GitHub releases or distribution channels"
echo ""
