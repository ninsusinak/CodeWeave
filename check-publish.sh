#!/bin/bash

# CodeWeave Pre-Publication Checklist
# Verifies all requirements before publishing

set -e

echo "🔍 CodeWeave Pre-Publication Checklist"
echo "======================================"
echo ""

ERRORS=0

# Check dotnet
echo "✓ Checking .NET SDK..."
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    echo "  ✅ .NET SDK found: $DOTNET_VERSION"
else
    echo "  ❌ .NET SDK not found"
    ERRORS=$((ERRORS+1))
fi
echo ""

# Check project file
echo "✓ Checking project structure..."
if [ -f "CodeWeave.UI/CodeWeave.UI.csproj" ]; then
    echo "  ✅ Project file found"
else
    echo "  ❌ Project file not found"
    ERRORS=$((ERRORS+1))
fi
echo ""

# Check assets
echo "✓ Checking asset files..."
ASSETS_OK=1

if [ -f "CodeWeave.UI/assets/CodeWeaver.ico" ]; then
    echo "  ✅ Windows icon found"
else
    echo "  ❌ Windows icon missing (CodeWeaver.ico)"
    ASSETS_OK=0
fi

if [ -f "CodeWeave.UI/assets/CodeWeaver.icns" ]; then
    echo "  ✅ macOS icon found"
else
    echo "  ❌ macOS icon missing (CodeWeaver.icns)"
    ASSETS_OK=0
fi

if [ -f "CodeWeave.UI/assets/CodeWeaver_512.png" ]; then
    echo "  ✅ Linux icon found"
else
    echo "  ❌ Linux icon missing (CodeWeaver_512.png)"
    ASSETS_OK=0
fi

if [ $ASSETS_OK -eq 0 ]; then
    ERRORS=$((ERRORS+1))
fi
echo ""

# Check build scripts
echo "✓ Checking build scripts..."
SCRIPTS_OK=1

for script in package-mac.sh package-windows.sh package-linux.sh publish-all.sh; do
    if [ -f "$script" ]; then
        echo "  ✅ $script found"
    else
        echo "  ❌ $script not found"
        SCRIPTS_OK=0
    fi
done

if [ $SCRIPTS_OK -eq 0 ]; then
    ERRORS=$((ERRORS+1))
fi
echo ""

# Check git
echo "✓ Checking git repository..."
if [ -d ".git" ]; then
    echo "  ✅ Git repository found"
    if git status > /dev/null 2>&1; then
        REMOTE=$(git remote get-url origin 2>/dev/null || echo "not configured")
        echo "  📍 Remote: $REMOTE"
    fi
else
    echo "  ⚠️  Not a git repository"
fi
echo ""

# Try building
echo "✓ Testing build..."
if dotnet build CodeWeave.UI/CodeWeave.UI.csproj -c Release 2>&1 | grep -q "Build succeeded"; then
    echo "  ✅ Project builds successfully (Release)"
else
    echo "  ❌ Build failed"
    ERRORS=$((ERRORS+1))
fi
echo ""

# Final summary
echo "═══════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed! Ready to publish."
    echo ""
    echo "Run: ./publish-all.sh"
    exit 0
else
    echo "❌ $ERRORS check(s) failed. Please fix before publishing."
    exit 1
fi
