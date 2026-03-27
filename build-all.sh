#!/bin/bash

# Build script for CodeWeave - Cross-platform builds

set -e

PROJECT_PATH="CodeWeave.UI/CodeWeave.UI.csproj"
OUTPUT_DIR="dist"

echo "🔨 Building CodeWeave for all platforms..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Windows x64
echo "📦 Building for Windows x64..."
dotnet publish "$PROJECT_PATH" -c Release -r win-x64 -o "$OUTPUT_DIR/win-x64"

# Windows ARM64
echo "📦 Building for Windows ARM64..."
dotnet publish "$PROJECT_PATH" -c Release -r win-arm64 -o "$OUTPUT_DIR/win-arm64"

# macOS x64
echo "📦 Building for macOS x64..."
dotnet publish "$PROJECT_PATH" -c Release -r osx-x64 -o "$OUTPUT_DIR/mac-x64"

# macOS ARM64 (Apple Silicon)
echo "📦 Building for macOS ARM64..."
dotnet publish "$PROJECT_PATH" -c Release -r osx-arm64 -o "$OUTPUT_DIR/mac-arm64"

# Linux x64
echo "📦 Building for Linux x64..."
dotnet publish "$PROJECT_PATH" -c Release -r linux-x64 -o "$OUTPUT_DIR/linux-x64"

# Linux ARM64
echo "📦 Building for Linux ARM64..."
dotnet publish "$PROJECT_PATH" -c Release -r linux-arm64 -o "$OUTPUT_DIR/linux-arm64"

echo "✅ All builds completed successfully!"
echo "📁 Outputs are in the $OUTPUT_DIR directory"
