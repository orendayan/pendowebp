# PendoWebP

Pendo's internal fork of Google's libwebp with namespaced symbols to prevent dependency conflicts.

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.3.2-green.svg)](https://github.com/orendayan/pendowebp/releases)

## What is this?

Namespaced fork of [Google's libwebp](https://chromium.googlesource.com/webm/libwebp) v1.3.2 with all **107 public symbols** prefixed with `Pendo_` to prevent dependency conflicts.

### Why Fork?

Allows Pendo plugins to use a stable version of libwebp while apps can use any other version (including official libwebp 2.0+) without conflicts.

**Example:**
```objective-c
// Your plugin using PendoWebP
Pendo_WebPEncodeRGBA(...)  // ← Namespaced

// App using official libwebp  
WebPEncodeRGBA(...)        // ← Original

// ✅ Both coexist! No conflicts!
```

## Installation

### 1. Add to Podfile

```ruby
pod 'PendoWebP', :git => 'https://github.com/orendayan/pendowebp.git', :tag => 'v1.3.2'
```

### 2. Add Required Hook

**⚠️ CRITICAL:** See [INSTALLATION.md](INSTALLATION.md) for the required `post_install` hook.

### 3. Install

```bash
pod install
```

## Usage

### 📖 Complete Guides

- **[Objective-C Usage Guide](USAGE_OBJC.md)** - Complete examples for Objective-C
- **[Swift & SwiftUI Usage Guide](USAGE_SWIFT.md)** - Modern Swift and SwiftUI examples

### Quick Examples

**Objective-C:**
```objective-c
#import <webp/encode.h>

uint8_t *output = NULL;
size_t size = Pendo_WebPEncodeRGBA(
    pixels, 
    width, 
    height, 
    stride, 
    85.0f,  // quality 0-100
    &output
);

NSData *webpData = [NSData dataWithBytes:output length:size];
Pendo_WebPFree(output);  // Always free!
```

**Swift:**
```swift
import PendoWebP

// Using the wrapper (see USAGE_SWIFT.md)
let webpData = PendoWebPEncoder.encode(image, quality: 0.85)

// Or with UIImage extension
let webpData = myImage.webPData(quality: 0.85)
```

**SwiftUI:**
```swift
Button("Compress") {
    Task {
        let webpData = try await ImageCompressor.compressToWebP(image)
    }
}
```

## Features

- ✅ **Zero Conflicts** - All symbols prefixed with `Pendo_`
- ✅ **Drop-in Replacement** - Same API as libwebp, just add prefix
- ✅ **Production Ready** - Based on stable libwebp 1.3.2
- ✅ **Well Documented** - Complete guides for Objective-C and Swift
- ✅ **BSD Licensed** - Same as original libwebp

## Symbol Mapping

All 107 public functions are prefixed:

```c
// Original              // PendoWebP
WebPEncodeRGBA()    →   Pendo_WebPEncodeRGBA()
WebPFree()          →   Pendo_WebPFree()
WebPGetInfo()       →   Pendo_WebPGetInfo()
// ... etc
```

See [RENAMED_SYMBOLS.txt](RENAMED_SYMBOLS.txt) for the complete list.

## Documentation

- 📖 [INSTALLATION.md](INSTALLATION.md) - Installation with required Podfile hook
- 📖 [USAGE_OBJC.md](USAGE_OBJC.md) - Objective-C examples and API reference
- 📖 [USAGE_SWIFT.md](USAGE_SWIFT.md) - Swift and SwiftUI examples
- 📖 [RENAMED_SYMBOLS.txt](RENAMED_SYMBOLS.txt) - Complete symbol mapping

## Version

**1.3.2** - Based on libwebp 1.3.2

## License

BSD 3-Clause License (same as original libwebp)

**Copyright:**
- © 2010 Google Inc. (original libwebp)
- © 2025 Pendo.io Inc. (namespaced fork)

See [LICENSE](LICENSE) and [COPYING](COPYING) for details.
