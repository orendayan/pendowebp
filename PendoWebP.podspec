#
# PendoWebP.podspec
# Namespaced fork of Google's libwebp for internal Pendo projects
#

Pod::Spec.new do |s|
  s.name             = 'PendoWebP'
  s.version          = '1.3.2'
  s.summary          = 'Pendo-namespaced fork of Google libwebp'
  
  s.description      = <<-DESC
PendoWebP is a namespaced fork of Google's libwebp library (v1.3.2).
All public symbols are prefixed with Pendo_ to prevent dependency conflicts.

This allows Pendo plugins to use a stable version of libwebp while
allowing apps to use any version of the official libwebp without conflicts.

Renamed symbols:
- WebPEncodeRGBA() → Pendo_WebPEncodeRGBA()
- WebPFree() → Pendo_WebPFree()
- All other public APIs similarly prefixed

Based on: https://chromium.googlesource.com/webm/libwebp @ v1.3.2
                       DESC
  
  s.homepage         = 'https://github.com/pendo-io/pendowebp'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.author           = { 'Pendo' => 'dev@pendo.io' }
  
  # Source location - UPDATE THIS to your repository
  s.source           = { 
    :git => 'https://github.com/pendo-io/pendowebp.git', 
    :tag => "v#{s.version}" 
  }
  
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  
  # Preserve original module structure
  s.module_name = 'PendoWebP'
  
  # Source files - include all libwebp components
  s.source_files = [
    'src/**/*.{h,c}',           # All source files
    'sharpyuv/**/*.{h,c}'       # SharpYUV
  ]
  
  # Public headers (what users can import)
  s.public_header_files = 'src/webp/*.h'
  
  # Private headers (internal use, still need to be accessible during compilation)
  s.private_header_files = [
    'src/dec/**/*.h',
    'src/dsp/**/*.h',
    'src/enc/**/*.h',
    'src/mux/**/*.h',
    'src/utils/**/*.h',
    'sharpyuv/**/*.h'
  ]
  
  # Compiler flags
  s.compiler_flags = [
    '-DWEBP_USE_THREAD',        # Enable threading
    '-DHAVE_CONFIG_H'           # Use config
  ]
  
  # System frameworks needed
  s.frameworks = 'Foundation', 'CoreGraphics', 'Accelerate'
  
  # Build settings
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) ${PODS_ROOT}/PendoWebP ${PODS_ROOT}/PendoWebP/src ${PODS_ROOT}/PendoWebP/src/dec ${PODS_ROOT}/PendoWebP/src/dsp ${PODS_ROOT}/PendoWebP/src/enc ${PODS_ROOT}/PendoWebP/src/mux ${PODS_ROOT}/PendoWebP/src/utils ${PODS_ROOT}/PendoWebP/src/webp ${PODS_ROOT}/PendoWebP/sharpyuv',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) WEBP_USE_THREAD=1',
    'WARNING_CFLAGS' => '-Wno-shorten-64-to-32 -Wno-comma -Wno-unreachable-code',
    'DEFINES_MODULE' => 'YES',
    'USE_HEADERMAP' => 'YES'
  }
  
  # Not ARC (C library)
  s.requires_arc = false
  
  # Library settings
  s.libraries = 'c++'
  
  # Prepare command (optional optimizations)
  s.prepare_command = <<-CMD
    # Optional: Generate config.h if needed
    # echo "Preparing PendoWebP..."
  CMD
end

