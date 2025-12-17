#!/bin/bash
set -e

echo "Fixing all include paths permanently..."

# Fix src/ files
find src -type f \( -name "*.c" -o -name "*.h" \) -exec sed -i '' \
  -e 's|"src/dsp/|"|g' \
  -e 's|"src/dec/|"../dec/|g' \
  -e 's|"src/enc/|"../enc/|g' \
  -e 's|"src/utils/|"../utils/|g' \
  -e 's|"src/mux/|"../mux/|g' \
  -e 's|"src/demux/|"../demux/|g' \
  -e 's|"src/webp/|"../webp/|g' \
  -e 's|"sharpyuv/|"../../sharpyuv/|g' \
  {} \;

# Fix sharpyuv/ files  
find sharpyuv -type f \( -name "*.c" -o -name "*.h" \) -exec sed -i '' \
  -e 's|"sharpyuv/|"|g' \
  -e 's|"src/webp/|"../src/webp/|g' \
  -e 's|"src/dsp/cpu.c"|"../src/dsp/cpu.c"|g' \
  -e 's|"src/dsp/cpu.h"|"../src/dsp/cpu.h"|g' \
  {} \;

# Remove config.h includes
find . -type f \( -name "*.c" -o -name "*.h" \) -not -path "./backup*" -exec sed -i '' \
  -e 's|#include "../webp/config.h"|// config.h removed for CocoaPods|g' \
  -e 's|#include "src/webp/config.h"|// config.h removed for CocoaPods|g' \
  {} \;

echo "✓ All includes fixed permanently!"
