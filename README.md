# PendoWebP

Pendo's internal fork of Google's libwebp with namespaced symbols.

## What is this?

Namespaced fork of [Google's libwebp](https://chromium.googlesource.com/webm/libwebp) v1.3.2
with all public symbols prefixed with `Pendo_` to prevent dependency conflicts.

## Why?

Allows Pendo plugins to use libwebp while apps can still use official libwebp (any version) without conflicts.

## Installation

```ruby
# Via git (recommended)
pod 'PendoWebP', :git => 'https://github.com/YOUR-ORG/pendowebp.git', :tag => 'v1.3.2'
```

## Usage

```objective-c
#import <webp/encode.h>

uint8_t *output;
size_t size = Pendo_WebPEncodeRGBA(pixels, width, height, stride, quality, &output);
Pendo_WebPFree(output);
```

## License

BSD License (same as libwebp)
