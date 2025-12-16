#
# PendoWebP.podspec
# Namespaced fork of Google's libwebp for internal Pendo projects
# Based on official libwebp 1.3.2 podspec structure
#

Pod::Spec.new do |s|
  s.name             = 'PendoWebP'
  s.version          = '1.3.2'
  s.summary          = 'Pendo-namespaced fork of Google libwebp'
  
  s.description      = <<-DESC
PendoWebP is a namespaced fork of Google's libwebp library (v1.3.2).
All public symbols are prefixed with Pendo_ to prevent dependency conflicts.

Based on: https://chromium.googlesource.com/webm/libwebp @ v1.3.2
                       DESC
  
  s.homepage         = 'https://github.com/orendayan/pendowebp'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.author           = { 'Pendo' => 'dev@pendo.io' }
  s.source           = { 
    :git => 'https://github.com/orendayan/pendowebp.git', 
    :tag => "v#{s.version}" 
  }
  
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  
  s.module_name = 'PendoWebP'
  s.requires_arc = false
  
  # CRITICAL: Match official libwebp exactly
  s.pod_target_xcconfig = {
    'USER_HEADER_SEARCH_PATHS' => '$(inherited) ${PODS_ROOT}/PendoWebP/ ${PODS_TARGET_SRCROOT}/',
    'USE_HEADERMAP' => 'YES'
  }
  
  # This is CRITICAL for finding src/dsp/yuv.h from src/dsp/yuv_neon.c
  s.preserve_paths = 'src'
  
  # Use subspecs like official libwebp for proper header resolution
  s.default_subspecs = ['sharpyuv', 'webp', 'demux', 'mux']
  
  # SharpYUV subspec
  s.subspec 'sharpyuv' do |ss|
    ss.source_files = 'sharpyuv/*.{h,c}'
    ss.public_header_files = 'sharpyuv/sharpyuv.h'
  end
  
  # Core WebP subspec
  s.subspec 'webp' do |ss|
    ss.dependency 'PendoWebP/sharpyuv'
    
    ss.source_files = [
      'src/webp/decode.h',
      'src/webp/encode.h',
      'src/webp/types.h',
      'src/webp/mux_types.h',
      'src/webp/format_constants.h',
      'src/utils/*.{h,c}',
      'src/dsp/*.{h,c}',
      'src/dec/*.{h,c}',
      'src/enc/*.{h,c}'
    ]
    
    ss.public_header_files = [
      'src/webp/decode.h',
      'src/webp/encode.h',
      'src/webp/types.h',
      'src/webp/mux_types.h',
      'src/webp/format_constants.h'
    ]
  end
  
  # Demux subspec
  s.subspec 'demux' do |ss|
    ss.dependency 'PendoWebP/webp'
    
    ss.source_files = [
      'src/demux/*.{h,c}',
      'src/webp/demux.h'
    ]
    
    ss.public_header_files = 'src/webp/demux.h'
  end
  
  # Mux subspec
  s.subspec 'mux' do |ss|
    ss.dependency 'PendoWebP/demux'
    
    ss.source_files = [
      'src/mux/*.{h,c}',
      'src/webp/mux.h'
    ]
    
    ss.public_header_files = 'src/webp/mux.h'
  end
  
  # Compiler flags
  s.compiler_flags = '-DWEBP_USE_THREAD'
  s.frameworks = 'Foundation', 'CoreGraphics', 'Accelerate'
  s.libraries = 'c++'
end
