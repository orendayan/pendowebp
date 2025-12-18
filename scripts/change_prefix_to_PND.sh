#!/bin/bash
set -e

echo "Changing symbol prefix from Pendo_ to PND..."

# Change all Pendo_WebP to PNDWebP in source files
find src -type f \( -name "*.c" -o -name "*.h" \) -exec sed -i '' 's/Pendo_WebP/PNDWebP/g' {} \;
find sharpyuv -type f \( -name "*.c" -o -name "*.h" \) -exec sed -i '' 's/Pendo_WebP/PNDWebP/g' {} \;

# Update documentation
sed -i '' 's/Pendo_WebP/PNDWebP/g' README.md
sed -i '' 's/Pendo_WebP/PNDWebP/g' USAGE_OBJC.md 2>/dev/null || true
sed -i '' 's/Pendo_WebP/PNDWebP/g' USAGE_SWIFT.md 2>/dev/null || true
sed -i '' 's/Pendo_WebP/PNDWebP/g' INSTALLATION.md 2>/dev/null || true
sed -i '' 's/Pendo_WebP/PNDWebP/g' RENAMED_SYMBOLS.txt 2>/dev/null || true

echo "✓ Changed Pendo_ to PND"
echo ""
echo "Examples:"
echo "  Pendo_WebPEncodeRGBA → PNDWebPEncodeRGBA"
echo "  Pendo_WebPFree → PNDWebPFree"
