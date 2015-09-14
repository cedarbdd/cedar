Pod::Spec.new do |s|
  s.name     = 'Cedar'
  s.version  = '0.11.3'
  s.license  = 'MIT'
  s.summary  = 'BDD-style testing using Objective-C.'
  s.homepage = 'https://github.com/pivotal/cedar'
  s.author   = { 'Pivotal Labs' => 'http://pivotallabs.com' }
  s.license  = { :type => 'MIT', :file => 'MIT.LICENSE.txt' }
  s.source   = { :git => 'https://github.com/pivotal/cedar.git', :tag => 'v0.11.3' }

  s.osx.deployment_target = '10.7'
  s.ios.deployment_target = '6.0'
  s.source_files = 'Source/**/*.{h,m,mm}'
  s.public_header_files = 'Source/Headers/Public/**/*.{h}'
  s.osx.exclude_files = '**/iPhone/**'
  s.ios.exclude_files = '**/OSX/**'

  # Versions of this pod >= 0.9.0 require C++11.
  #   https://github.com/pivotal/cedar/issues/47
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++0x',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'OTHER_CFLAGS' => '-DDEVELOPER_BIN_DIR=@\"${DEVELOPER_BIN_DIR}\"'
  }
  s.libraries = 'c++'
  s.requires_arc = false

end
