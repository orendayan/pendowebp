# Using PendoWebP in iOS Objective-C

Complete guide for using PendoWebP (namespaced libwebp) in your iOS applications.

## Installation

### 1. Add to Podfile

```ruby
pod 'PendoWebP', :git => 'https://github.com/orendayan/pendowebp.git', :tag => 'v1.3.2'
```

### 2. Add Required post_install Hook

**⚠️ CRITICAL:** Add this hook to your Podfile (see INSTALLATION.md for complete hook code).

### 3. Install

```bash
cd ios
pod install
```

## Basic Usage

### Import Headers

```objective-c
#import <webp/encode.h>  // For encoding
#import <webp/decode.h>  // For decoding (optional)
#import <webp/types.h>   // For types
```

## Encoding Examples

### Example 1: Encode UIImage to WebP

```objective-c
#import <webp/encode.h>

- (NSData *)encodeImageToWebP:(UIImage *)image quality:(float)quality {
    CGImageRef cgImage = image.CGImage;
    if (!cgImage) return nil;
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    
    // Create RGBA bitmap
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
        NULL,
        width,
        height,
        8,
        width * 4,
        colorSpace,
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault
    );
    CGColorSpaceRelease(colorSpace);
    
    if (!context) return nil;
    
    // Draw image
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    uint8_t *pixelData = CGBitmapContextGetData(context);
    
    // Encode with PendoWebP (note the Pendo_ prefix!)
    uint8_t *output = NULL;
    size_t outputSize = Pendo_WebPEncodeRGBA(
        pixelData,
        (int)width,
        (int)height,
        (int)(width * 4),  // stride
        quality * 100.0f,  // quality (0-100)
        &output
    );
    
    CGContextRelease(context);
    
    if (outputSize == 0 || !output) {
        if (output) Pendo_WebPFree(output);
        return nil;
    }
    
    // Convert to NSData
    NSData *webpData = [NSData dataWithBytes:output length:outputSize];
    
    // IMPORTANT: Free the memory!
    Pendo_WebPFree(output);
    
    return webpData;
}
```

### Example 2: Encode with Lossless Compression

```objective-c
- (NSData *)encodeLosslessWebP:(UIImage *)image {
    CGImageRef cgImage = image.CGImage;
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    
    // ... create context and get pixelData (same as above) ...
    
    // Use lossless encoding (note Pendo_ prefix!)
    uint8_t *output = NULL;
    size_t outputSize = Pendo_WebPEncodeLosslessRGBA(
        pixelData,
        (int)width,
        (int)height,
        (int)(width * 4)
    );
    
    // ... rest same as above ...
}
```

### Example 3: Advanced Encoding with Config

```objective-c
#import <webp/encode.h>

- (NSData *)advancedWebPEncode:(UIImage *)image {
    // ... setup context and pixelData ...
    
    // Configure encoding (note Pendo_ prefix!)
    WebPConfig config;
    if (!Pendo_WebPConfigInit(&config)) {
        return nil;
    }
    
    // Customize settings
    config.quality = 85.0f;
    config.method = 6;  // 0=fast, 6=slower but better
    config.target_size = 0;  // 0=no target
    config.alpha_compression = 1;
    
    // Validate config
    if (!Pendo_WebPValidateConfig(&config)) {
        return nil;
    }
    
    // Setup picture (note Pendo_ prefix!)
    WebPPicture picture;
    if (!Pendo_WebPPictureInit(&picture)) {
        return nil;
    }
    
    picture.width = (int)width;
    picture.height = (int)height;
    picture.use_argb = 1;
    
    // Import RGBA data
    if (!Pendo_WebPPictureImportRGBA(&picture, pixelData, (int)(width * 4))) {
        Pendo_WebPPictureFree(&picture);
        return nil;
    }
    
    // Setup writer
    WebPMemoryWriter writer;
    Pendo_WebPMemoryWriterInit(&writer);
    picture.writer = Pendo_WebPMemoryWrite;
    picture.custom_ptr = &writer;
    
    // Encode (note Pendo_ prefix!)
    int success = Pendo_WebPEncode(&config, &picture);
    
    NSData *result = nil;
    if (success) {
        result = [NSData dataWithBytes:writer.mem length:writer.size];
    }
    
    // Cleanup (note Pendo_ prefix!)
    Pendo_WebPPictureFree(&picture);
    Pendo_WebPMemoryWriterClear(&writer);
    
    return result;
}
```

## Decoding Examples

### Example 4: Decode WebP to UIImage

```objective-c
#import <webp/decode.h>

- (UIImage *)decodeWebP:(NSData *)webpData {
    const uint8_t *data = webpData.bytes;
    size_t dataSize = webpData.length;
    
    int width, height;
    // Get image info (note Pendo_ prefix!)
    if (!Pendo_WebPGetInfo(data, dataSize, &width, &height)) {
        return nil;
    }
    
    // Decode to RGBA (note Pendo_ prefix!)
    uint8_t *rgba = Pendo_WebPDecodeRGBA(data, dataSize, &width, &height);
    if (!rgba) return nil;
    
    // Create CGImage
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
        rgba,
        width,
        height,
        8,
        width * 4,
        colorSpace,
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault
    );
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    CGContextRelease(context);
    
    // Free WebP memory (note Pendo_ prefix!)
    Pendo_WebPFree(rgba);
    
    return image;
}
```

## 🔑 Key Differences from Official libwebp

### Symbol Names

**Official libwebp:**
```objective-c
WebPEncodeRGBA(...)
WebPFree(...)
WebPGetInfo(...)
```

**PendoWebP (your fork):**
```objective-c
Pendo_WebPEncodeRGBA(...)  // ← Pendo_ prefix!
Pendo_WebPFree(...)        // ← Pendo_ prefix!
Pendo_WebPGetInfo(...)     // ← Pendo_ prefix!
```

**All 107 functions have the `Pendo_` prefix!**

### Why This Matters

This allows your app to use BOTH:

```objective-c
// Your plugin using PendoWebP
size_t size1 = Pendo_WebPEncodeRGBA(...);  // Your namespaced version

// App or other library using official libwebp
size_t size2 = WebPEncodeRGBA(...);        // Official version

// ✅ NO CONFLICT! Different symbol names
```

## Common Encoding Functions

### Simple Encoding (Most Common)

```objective-c
// RGBA format
Pendo_WebPEncodeRGBA(const uint8_t* rgba, int width, int height, int stride, float quality, uint8_t** output)

// RGB format (no alpha)
Pendo_WebPEncodeRGB(const uint8_t* rgb, int width, int height, int stride, float quality, uint8_t** output)

// BGR format
Pendo_WebPEncodeBGR(const uint8_t* bgr, int width, int height, int stride, float quality, uint8_t** output)

// BGRA format
Pendo_WebPEncodeBGRA(const uint8_t* bgra, int width, int height, int stride, float quality, uint8_t** output)
```

### Lossless Encoding

```objective-c
Pendo_WebPEncodeLosslessRGBA(const uint8_t* rgba, int width, int height, int stride, uint8_t** output)
Pendo_WebPEncodeLosslessRGB(const uint8_t* rgb, int width, int height, int stride, uint8_t** output)
```

## Memory Management

**CRITICAL:** Always free WebP-allocated memory!

```objective-c
uint8_t *output = NULL;
size_t size = Pendo_WebPEncodeRGBA(..., &output);

if (size > 0 && output) {
    // Use the data
    NSData *webpData = [NSData dataWithBytes:output length:size];
    
    // MUST FREE!
    Pendo_WebPFree(output);  // ← Don't forget this!
}
```

## Complete Example: UIImage → WebP File

```objective-c
#import <webp/encode.h>

- (BOOL)saveImage:(UIImage *)image toWebPFile:(NSString *)path quality:(float)quality {
    // Get CGImage
    CGImageRef cgImage = image.CGImage;
    if (!cgImage) return NO;
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    
    // Create bitmap context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *pixelData = calloc(width * height * 4, 1);
    
    CGContextRef context = CGBitmapContextCreate(
        pixelData,
        width,
        height,
        8,
        width * 4,
        colorSpace,
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault
    );
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        free(pixelData);
        return NO;
    }
    
    // Draw image
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    CGContextRelease(context);
    
    // Encode to WebP (note Pendo_ prefix!)
    uint8_t *output = NULL;
    size_t outputSize = Pendo_WebPEncodeRGBA(
        pixelData,
        (int)width,
        (int)height,
        (int)(width * 4),
        quality * 100.0f,
        &output
    );
    
    free(pixelData);
    
    if (outputSize == 0 || !output) {
        if (output) Pendo_WebPFree(output);
        return NO;
    }
    
    // Save to file
    NSData *webpData = [NSData dataWithBytes:output length:outputSize];
    Pendo_WebPFree(output);  // Free WebP memory
    
    return [webpData writeToFile:path atomically:YES];
}

// Usage:
// [self saveImage:myImage toWebPFile:@"/path/to/image.webp" quality:0.85f];
```

## Error Handling

```objective-c
uint8_t *output = NULL;
size_t size = Pendo_WebPEncodeRGBA(..., &output);

if (size == 0) {
    NSLog(@"WebP encoding failed!");
    if (output) Pendo_WebPFree(output);  // Clean up if allocated
    return nil;
}

// Success - use the data
NSData *webpData = [NSData dataWithBytes:output length:size];
Pendo_WebPFree(output);
```

## Performance Tips

### 1. Quality Settings

```objective-c
float quality;

quality = 0.90f;  // 90% - High quality, larger file
quality = 0.85f;  // 85% - Good balance (recommended)
quality = 0.75f;  // 75% - Good compression, smaller file
quality = 0.60f;  // 60% - Maximum compression
```

### 2. Use Background Thread

```objective-c
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *webpData = [self encodeImageToWebP:image quality:0.85f];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update UI with result
    });
});
```

### 3. Reuse Contexts

For batch processing, reuse CGContext:

```objective-c
CGContextRef context = /* create once */;

for (UIImage *image in images) {
    // Clear context
    CGContextClearRect(context, CGRectMake(0, 0, width, height));
    
    // Draw and encode
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    uint8_t *pixelData = CGBitmapContextGetData(context);
    
    uint8_t *output = NULL;
    size_t size = Pendo_WebPEncodeRGBA(..., &output);
    
    // Process output...
    Pendo_WebPFree(output);
}

CGContextRelease(context);  // Release once at end
```

## Complete Function Reference

### Encoding Functions (Simple API)

```objective-c
// All return size_t (output size), 0 on failure
// All have Pendo_ prefix!

Pendo_WebPEncodeRGBA(rgba, width, height, stride, quality, &output)
Pendo_WebPEncodeBGRA(bgra, width, height, stride, quality, &output)
Pendo_WebPEncodeRGB(rgb, width, height, stride, quality, &output)
Pendo_WebPEncodeBGR(bgr, width, height, stride, quality, &output)

// Lossless variants
Pendo_WebPEncodeLosslessRGBA(rgba, width, height, stride, &output)
Pendo_WebPEncodeLosslessBGRA(bgra, width, height, stride, &output)
Pendo_WebPEncodeLosslessRGB(rgb, width, height, stride, &output)
Pendo_WebPEncodeLosslessBGR(bgr, width, height, stride, &output)
```

### Memory Management

```objective-c
// Free memory allocated by WebP functions
Pendo_WebPFree(void *ptr)

// Allocate memory (rarely needed)
Pendo_WebPMalloc(size_t size)
```

### Decoding Functions

```objective-c
// Simple decoding
Pendo_WebPDecodeRGBA(data, data_size, &width, &height)
Pendo_WebPDecodeARGB(data, data_size, &width, &height)
Pendo_WebPDecodeBGRA(data, data_size, &width, &height)

// Get image info without decoding
Pendo_WebPGetInfo(data, data_size, &width, &height)
```

## Helper Class Example

Create a reusable WebP encoder class:

```objective-c
// PendoWebPHelper.h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PendoWebPHelper : NSObject

+ (NSData *)encodeImage:(UIImage *)image quality:(CGFloat)quality;
+ (NSData *)encodeLossless:(UIImage *)image;
+ (UIImage *)decodeWebP:(NSData *)webpData;

@end

// PendoWebPHelper.m
#import "PendoWebPHelper.h"
#import <webp/encode.h>
#import <webp/decode.h>

@implementation PendoWebPHelper

+ (NSData *)encodeImage:(UIImage *)image quality:(CGFloat)quality {
    CGImageRef cgImage = image.CGImage;
    if (!cgImage) return nil;
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    
    // Create RGBA bitmap
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
        NULL, width, height, 8, width * 4,
        colorSpace,
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault
    );
    CGColorSpaceRelease(colorSpace);
    
    if (!context) return nil;
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    uint8_t *pixelData = CGBitmapContextGetData(context);
    
    // Encode (note Pendo_ prefix!)
    uint8_t *output = NULL;
    size_t size = Pendo_WebPEncodeRGBA(
        pixelData,
        (int)width,
        (int)height,
        (int)(width * 4),
        (float)(quality * 100.0),
        &output
    );
    
    CGContextRelease(context);
    
    if (size == 0 || !output) {
        if (output) Pendo_WebPFree(output);
        return nil;
    }
    
    NSData *webpData = [NSData dataWithBytes:output length:size];
    Pendo_WebPFree(output);
    
    return webpData;
}

+ (NSData *)encodeLossless:(UIImage *)image {
    // Similar to above but use Pendo_WebPEncodeLosslessRGBA
    // ...
}

+ (UIImage *)decodeWebP:(NSData *)webpData {
    int width, height;
    uint8_t *rgba = Pendo_WebPDecodeRGBA(
        webpData.bytes,
        webpData.length,
        &width,
        &height
    );
    
    if (!rgba) return nil;
    
    // Create UIImage from RGBA data
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
        rgba, width, height, 8, width * 4,
        colorSpace,
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault
    );
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    CGContextRelease(context);
    Pendo_WebPFree(rgba);
    
    return image;
}

@end
```

## Usage in Your App

```objective-c
#import "PendoWebPHelper.h"

// Encode
UIImage *myImage = [UIImage imageNamed:@"photo.jpg"];
NSData *webpData = [PendoWebPHelper encodeImage:myImage quality:0.85];
[webpData writeToFile:@"photo.webp" atomically:YES];

// Decode
NSData *webpData = [NSData dataWithContentsOfFile:@"photo.webp"];
UIImage *decodedImage = [PendoWebPHelper decodeWebP:webpData];
```

## Common Pitfalls

### ❌ Forgetting to Free Memory

```objective-c
// BAD - Memory leak!
uint8_t *output = NULL;
Pendo_WebPEncodeRGBA(..., &output);
return [NSData dataWithBytes:output length:size];  // Leaked!
```

```objective-c
// GOOD
uint8_t *output = NULL;
size_t size = Pendo_WebPEncodeRGBA(..., &output);
NSData *data = [NSData dataWithBytes:output length:size];
Pendo_WebPFree(output);  // ✓ Freed!
return data;
```

### ❌ Using Wrong Symbol Names

```objective-c
// BAD - Won't compile with PendoWebP!
WebPEncodeRGBA(...);  // Missing Pendo_ prefix

// GOOD
Pendo_WebPEncodeRGBA(...);  // ✓ Correct!
```

### ❌ Wrong Quality Range

```objective-c
// BAD
Pendo_WebPEncodeRGBA(..., 0.85f, ...);  // Wrong! API wants 0-100

// GOOD
Pendo_WebPEncodeRGBA(..., 85.0f, ...);  // Correct! 0-100 range
```

## See Also

- Complete symbol list: [RENAMED_SYMBOLS.txt](RENAMED_SYMBOLS.txt)
- Installation instructions: [INSTALLATION.md](INSTALLATION.md)
- Original libwebp docs: https://developers.google.com/speed/webp/docs/api

## Support

For issues specific to PendoWebP (the fork):
- Check INSTALLATION.md for Podfile hook
- Verify symbols have Pendo_ prefix
- Ensure post_install hook ran

For libwebp API questions:
- See official libwebp documentation
- All APIs work the same, just add Pendo_ prefix

