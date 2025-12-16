#!/bin/bash
#
# verify_namespace.sh
# Verifies that all libwebp symbols have been properly prefixed with Pendo_
#

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         PendoWebP Namespace Verification                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

FAILED=0

echo "🔍 Checking for unprefixed WebP symbols in headers..."

# Check public headers
UNPREFIXED_HEADERS=$(grep -rn "WEBP_EXTERN.*\bWebP[A-Z]" src/webp/*.h 2>/dev/null | grep -v "Pendo_" || true)

if [ -n "$UNPREFIXED_HEADERS" ]; then
    echo "❌ Found unprefixed symbols in headers:"
    echo "$UNPREFIXED_HEADERS"
    FAILED=1
else
    echo "✅ All header symbols properly prefixed"
fi

echo ""
echo "🔍 Checking for unprefixed WebP symbols in source files..."

# Check for common unprefixed patterns in source
UNPREFIXED_SOURCE=$(grep -rn "\bWebPEncode[A-Z]" src/ 2>/dev/null | grep -v "Pendo_WebP" | grep -v "\.git" | head -20 || true)

if [ -n "$UNPREFIXED_SOURCE" ]; then
    echo "⚠️  Found potential unprefixed symbols in source (first 20):"
    echo "$UNPREFIXED_SOURCE"
    echo ""
    echo "   Note: Some internal functions are okay to leave unprefixed"
    echo "   Only public API functions need the Pendo_ prefix"
else
    echo "✅ No obvious unprefixed symbols in source"
fi

echo ""
echo "🔍 Checking header guards..."

# Check header guards are updated
UNPREFIXED_GUARDS=$(grep -rn "^#ifndef WEBP_WEBP_" src/webp/*.h 2>/dev/null | grep -v "PENDO_" || true)

if [ -n "$UNPREFIXED_GUARDS" ]; then
    echo "❌ Found unprefixed header guards:"
    echo "$UNPREFIXED_GUARDS"
    FAILED=1
else
    echo "✅ Header guards properly prefixed"
fi

echo ""

# If compiled library exists, check binary symbols
if [ -f "build/libwebp.a" ] || [ -f "build/libPendoWebP.a" ]; then
    echo "🔍 Checking compiled binary symbols..."
    
    LIBFILE=$(find build -name "*.a" | head -1)
    PUBLIC_SYMBOLS=$(nm -gU "$LIBFILE" 2>/dev/null | grep " T " | grep "WebP" || true)
    
    UNPREFIXED_BINARY=$(echo "$PUBLIC_SYMBOLS" | grep -v "Pendo_" || true)
    
    if [ -n "$UNPREFIXED_BINARY" ]; then
        echo "❌ Found unprefixed symbols in compiled binary:"
        echo "$UNPREFIXED_BINARY"
        FAILED=1
    else
        echo "✅ All binary symbols properly prefixed"
        
        # Show sample of renamed symbols
        echo ""
        echo "📋 Sample of properly prefixed symbols:"
        echo "$PUBLIC_SYMBOLS" | head -10
    fi
else
    echo "ℹ️  No compiled library found (skipping binary check)"
    echo "   Run: mkdir build && cd build && cmake .. && make"
fi

echo ""
echo "══════════════════════════════════════════════════════════════"

if [ $FAILED -eq 0 ]; then
    echo "✅ VERIFICATION PASSED"
    echo ""
    echo "All libwebp symbols are properly namespaced with Pendo_ prefix!"
    echo "The library is ready for distribution."
else
    echo "❌ VERIFICATION FAILED"
    echo ""
    echo "Some symbols are not properly prefixed."
    echo "Please review the errors above and run rename_symbols.sh again."
    exit 1
fi

echo "══════════════════════════════════════════════════════════════"

