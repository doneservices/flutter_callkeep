#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_callkeep'
  s.version          = '0.3.0'
  s.summary          = 'iOS CallKit and Android incoming call bindings for Flutter'
  s.description      = <<-DESC
iOS CallKit and Android ConnectionService bindings for Flutter
                       DESC
  s.homepage         = 'http://doneservices.co'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Done' => 'kontakt@doneservices.se' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'CryptoSwift'


  s.ios.deployment_target = '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
