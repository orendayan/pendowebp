#!/bin/bash
set -e

echo "Renaming only function names (not macros)..."

# List of functions to rename
FUNCTIONS=(
    "WebPGetEncoderVersion" "WebPEncodeRGBA" "WebPEncodeBGRA" "WebPEncodeRGB" "WebPEncodeBGR"
    "WebPEncodeLosslessRGBA" "WebPEncodeLosslessBGRA" "WebPEncodeLosslessRGB" "WebPEncodeLosslessBGR"
    "WebPConfigInit" "WebPConfigInitInternal" "WebPConfigLosslessPreset" "WebPConfigPreset"
    "WebPValidateConfig" "WebPPictureInit" "WebPPictureInitInternal" "WebPPictureAlloc"
    "WebPPictureFree" "WebPPictureCopy" "WebPPictureIsView" "WebPPictureView"
    "WebPPictureCrop" "WebPPictureRescale" "WebPPictureImportRGB" "WebPPictureImportRGBA"
    "WebPPictureImportRGBX" "WebPPictureImportBGR" "WebPPictureImportBGRA" "WebPPictureImportBGRX"
    "WebPPictureARGBToYUVA" "WebPPictureARGBToYUVADithered" "WebPPictureSmartARGBToYUVA"
    "WebPPictureYUVAToARGB" "WebPPictureDistortion" "WebPEncode" "WebPMemoryWrite"
    "WebPMemoryWriterInit" "WebPMemoryWriterClear" "WebPGetDecoderVersion" "WebPGetInfo"
    "WebPDecodeRGBA" "WebPDecodeARGB" "WebPDecodeBGRA" "WebPDecodeRGB" "WebPDecodeBGR"
    "WebPDecodeRGBAInto" "WebPDecodeARGBInto" "WebPDecodeBGRAInto" "WebPDecodeRGBInto"
    "WebPDecodeBGRInto" "WebPDecodeYUVInto" "WebPDecodeYUV" "WebPINewDecoder"
    "WebPINewRGB" "WebPINewYUVA" "WebPINewYUV" "WebPIDelete" "WebPIAppend" "WebPIUpdate"
    "WebPIDecGetRGB" "WebPIDecGetYUVA" "WebPIDecodedArea" "WebPGetFeaturesInternal"
    "WebPGetFeatures" "WebPInitDecoderConfigInternal" "WebPInitDecoderConfig" "WebPDecode"
    "WebPFree" "WebPMalloc" "WebPSafeMalloc" "WebPSafeCalloc" "WebPGetMuxVersion"
    "WebPNewInternal" "WebPMuxNew" "WebPMuxDelete" "WebPMuxCreateInternal" "WebPMuxCreate"
    "WebPMuxSetChunk" "WebPMuxGetChunk" "WebPMuxDeleteChunk" "WebPMuxSetImage"
    "WebPMuxPushFrame" "WebPMuxGetFrame" "WebPMuxDeleteFrame" "WebPMuxSetAnimationParams"
    "WebPMuxGetAnimationParams" "WebPMuxSetCanvasSize" "WebPMuxGetCanvasSize"
    "WebPMuxGetFeatures" "WebPMuxNumChunks" "WebPMuxAssemble" "WebPGetDemuxVersion"
    "WebPDemuxInternal" "WebPDemux" "WebPDemuxPartial" "WebPDemuxDelete" "WebPDemuxGetI"
    "WebPDemuxGetFrame" "WebPDemuxNextFrame" "WebPDemuxPrevFrame" "WebPDemuxReleaseIterator"
    "WebPDemuxGetChunk" "WebPDemuxNextChunk" "WebPDemuxPrevChunk" "WebPDemuxReleaseChunkIterator"
    "WebPPlaneDistortion" "WebPCleanupTransparentArea" "WebPPictureHasTransparency" "WebPBlendAlpha"
    "WebPPictureSharpARGBToYUVA"
)

for func in "${FUNCTIONS[@]}"; do
    # Rename in all source and header files
    find src -type f \( -name "*.c" -o -name "*.h" \) -print0 | xargs -0 sed -i '' "s/\b${func}\(/Pendo_${func}(/g"
    find sharpyuv -type f \( -name "*.c" -o -name "*.h" \) -print0 | xargs -0 sed -i '' "s/\b${func}\(/Pendo_${func}(/g" 2>/dev/null || true
done

echo "✓ Function names renamed"
