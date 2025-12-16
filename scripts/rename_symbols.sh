#!/bin/bash
#
# rename_symbols.sh
# Renames all libwebp public symbols to Pendo_WebP* to prevent conflicts
#

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         PendoWebP Symbol Renaming Script                  ║"
echo "║  Renames all libwebp symbols to prevent conflicts         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if we're in the right directory
if [ ! -d "src" ] || [ ! -f "CMakeLists.txt" ]; then
    echo "❌ Error: Must be run from libwebp root directory"
    echo "   Expected structure: src/, CMakeLists.txt"
    exit 1
fi

echo "📍 Working directory: $(pwd)"
echo ""

# Prefix for all symbols
PREFIX="Pendo_"

echo "🔍 Symbol prefix: ${PREFIX}"
echo ""

# Complete list of all libwebp public API symbols
# Extracted from webp/encode.h, webp/decode.h, webp/mux.h, webp/demux.h
declare -a SYMBOLS=(
    # ===== ENCODING API (webp/encode.h) =====
    "WebPGetEncoderVersion"
    "WebPEncodeRGBA"
    "WebPEncodeBGRA"
    "WebPEncodeRGB"
    "WebPEncodeBGR"
    "WebPEncodeLosslessRGBA"
    "WebPEncodeLosslessBGRA"
    "WebPEncodeLosslessRGB"
    "WebPEncodeLosslessBGR"
    
    # Config and Picture API
    "WebPConfigInit"
    "WebPConfigInitInternal"
    "WebPConfigLosslessPreset"
    "WebPConfigPreset"
    "WebPValidateConfig"
    "WebPPictureInit"
    "WebPPictureInitInternal"
    "WebPPictureAlloc"
    "WebPPictureFree"
    "WebPPictureCopy"
    "WebPPictureIsView"
    "WebPPictureView"
    "WebPPictureCrop"
    "WebPPictureRescale"
    "WebPPictureImportRGB"
    "WebPPictureImportRGBA"
    "WebPPictureImportRGBX"
    "WebPPictureImportBGR"
    "WebPPictureImportBGRA"
    "WebPPictureImportBGRX"
    "WebPPictureARGBToYUVA"
    "WebPPictureARGBToYUVADithered"
    "WebPPictureSmartARGBToYUVA"
    "WebPPictureYUVAToARGB"
    "WebPPictureDistortion"
    "WebPEncode"
    
    # Writer callback
    "WebPMemoryWrite"
    "WebPMemoryWriterInit"
    "WebPMemoryWriterClear"
    
    # ===== DECODING API (webp/decode.h) =====
    "WebPGetDecoderVersion"
    "WebPGetInfo"
    "WebPDecodeRGBA"
    "WebPDecodeARGB"
    "WebPDecodeBGRA"
    "WebPDecodeRGB"
    "WebPDecodeBGR"
    "WebPDecodeRGBAInto"
    "WebPDecodeARGBInto"
    "WebPDecodeBGRAInto"
    "WebPDecodeRGBInto"
    "WebPDecodeBGRInto"
    "WebPDecodeYUVInto"
    "WebPDecodeYUV"
    
    # Incremental decoding
    "WebPINewDecoder"
    "WebPINewRGB"
    "WebPINewYUVA"
    "WebPINewYUV"
    "WebPIDelete"
    "WebPIAppend"
    "WebPIUpdate"
    "WebPIDecGetRGB"
    "WebPIDecGetYUVA"
    "WebPIDecodedArea"
    
    # Advanced decoding
    "WebPGetFeaturesInternal"
    "WebPGetFeatures"
    "WebPInitDecoderConfigInternal"
    "WebPInitDecoderConfig"
    "WebPDecode"
    
    # ===== MEMORY API =====
    "WebPFree"
    "WebPMalloc"
    "WebPSafeMalloc"
    "WebPSafeCalloc"
    
    # ===== MUX API (webp/mux.h) =====
    "WebPGetMuxVersion"
    "WebPNewInternal"
    "WebPMuxNew"
    "WebPMuxDelete"
    "WebPMuxCreateInternal"
    "WebPMuxCreate"
    "WebPMuxSetChunk"
    "WebPMuxGetChunk"
    "WebPMuxDeleteChunk"
    "WebPMuxSetImage"
    "WebPMuxPushFrame"
    "WebPMuxGetFrame"
    "WebPMuxDeleteFrame"
    "WebPMuxSetAnimationParams"
    "WebPMuxGetAnimationParams"
    "WebPMuxSetCanvasSize"
    "WebPMuxGetCanvasSize"
    "WebPMuxGetFeatures"
    "WebPMuxNumChunks"
    "WebPMuxAssemble"
    "WebPMuxGetError"
    
    # ===== DEMUX API (webp/demux.h) =====
    "WebPGetDemuxVersion"
    "WebPDemuxInternal"
    "WebPDemux"
    "WebPDemuxPartial"
    "WebPDemuxDelete"
    "WebPDemuxGetI"
    "WebPDemuxGetFrame"
    "WebPDemuxNextFrame"
    "WebPDemuxPrevFrame"
    "WebPDemuxReleaseIterator"
    "WebPDemuxGetChunk"
    "WebPDemuxNextChunk"
    "WebPDemuxPrevChunk"
    "WebPDemuxReleaseChunkIterator"
    
    # ===== TYPES API (webp/types.h) =====
    "WebPGetColorPalette"
)

echo "📊 Total symbols to rename: ${#SYMBOLS[@]}"
echo ""

# Create backup
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
echo "💾 Creating backup in: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r src "$BACKUP_DIR/"
echo "   ✓ Backup created"
echo ""

echo "🔄 Renaming symbols in source files..."
echo "   This may take a minute..."
echo ""

COUNT=0
for symbol in "${SYMBOLS[@]}"; do
    COUNT=$((COUNT + 1))
    
    # Show progress every 10 symbols
    if [ $((COUNT % 10)) -eq 0 ]; then
        echo "   Progress: $COUNT/${#SYMBOLS[@]} symbols..."
    fi
    
    # Rename in all C source files
    find src -type f -name "*.c" -exec sed -i '' "s/\b${symbol}\b/${PREFIX}${symbol}/g" {} + 2>/dev/null || true
    
    # Rename in all header files
    find src -type f -name "*.h" -exec sed -i '' "s/\b${symbol}\b/${PREFIX}${symbol}/g" {} + 2>/dev/null || true
    
    # Rename in sharpyuv directory
    find sharpyuv -type f \( -name "*.c" -o -name "*.h" \) -exec sed -i '' "s/\b${symbol}\b/${PREFIX}${symbol}/g" {} + 2>/dev/null || true
done

echo "   ✓ Renamed $COUNT symbols"
echo ""

echo "🔄 Updating header guards..."
# Update header guards to prevent conflicts
find src/webp -type f -name "*.h" -exec sed -i '' 's/WEBP_WEBP_/PENDO_WEBP_WEBP_/g' {} +
echo "   ✓ Header guards updated"
echo ""

echo "🔄 Updating macro definitions..."
# Update common macros
find src -type f \( -name "*.h" -o -name "*.c" \) -exec sed -i '' 's/WEBP_EXTERN/PENDO_WEBP_EXTERN/g' {} + 2>/dev/null || true
find src -type f \( -name "*.h" -o -name "*.c" \) -exec sed -i '' 's/WEBP_INLINE/PENDO_WEBP_INLINE/g' {} + 2>/dev/null || true
echo "   ✓ Macros updated"
echo ""

echo "📝 Creating symbol list for reference..."
cat > RENAMED_SYMBOLS.txt << EOF
# PendoWebP Renamed Symbols
# Generated: $(date)
# Original libwebp → PendoWebP mapping

EOF

for symbol in "${SYMBOLS[@]}"; do
    echo "${symbol} → ${PREFIX}${symbol}" >> RENAMED_SYMBOLS.txt
done

echo "   ✓ Symbol list saved to RENAMED_SYMBOLS.txt"
echo ""

echo "✅ Symbol renaming complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Review changes: git diff src/"
echo "   2. Run verification: ./scripts/verify_namespace.sh"
echo "   3. Test build: mkdir build && cd build && cmake .. && make"
echo "   4. Commit: git add . && git commit -m 'Add Pendo namespace to libwebp'"
echo ""
echo "💡 If anything went wrong, restore from backup: cp -r $BACKUP_DIR/src ."

