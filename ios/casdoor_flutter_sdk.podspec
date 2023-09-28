#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint casdoor_flutter_sdk.podspec` to validate before publishing.
#

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

current_dir = Dir.pwd
calling_dir = File.dirname(__FILE__)
project_dir = calling_dir.slice(0..(calling_dir.index('/.symlinks')))
flutter_project_dir = calling_dir.slice(0..(calling_dir.index('/ios/.symlinks')))

puts Psych::VERSION
psych_version_gte_500 = Gem::Version.new(Psych::VERSION) >= Gem::Version.new('5.0.0')
if psych_version_gte_500 == true
    cfg = YAML.load_file(File.join(flutter_project_dir, 'pubspec.yaml'), aliases: true)
else
    cfg = YAML.load_file(File.join(flutter_project_dir, 'pubspec.yaml'))
end

logging_status = "WECHAT_LOGGING=0"

if cfg['casdoor_flutter_sdk'] && cfg['casdoor_flutter_sdk']['debug_logging'] == true
    logging_status = 'WECHAT_LOGGING=1'
else
    logging_status = 'WECHAT_LOGGING=0'
end

scene_delegate = ''
if cfg['casdoor_flutter_sdk'] && cfg['casdoor_flutter_sdk']['ios'] && cfg['casdoor_flutter_sdk']['ios']['scene_delegate'] == true
    scene_delegate = 'SCENE_DELEGATE=1'
else
    scene_delegate = ''
end


if cfg['casdoor_flutter_sdk'] && cfg['casdoor_flutter_sdk']['ios'] && cfg['casdoor_flutter_sdk']['ios']['no_pay'] == true
    sdk_subspec = 'no_pay'
else
    sdk_subspec = 'pay'
end
Pod::UI.puts "using sdk with #{sdk_subspec}"

app_id = nil

if cfg['casdoor_flutter_sdk'] && cfg['casdoor_flutter_sdk']['app_id']
    app_id = cfg['casdoor_flutter_sdk']['app_id']
end


if cfg['casdoor_flutter_sdk'] && (cfg['casdoor_flutter_sdk']['ios']  && cfg['casdoor_flutter_sdk']['ios']['universal_link'])
    universal_link = cfg['casdoor_flutter_sdk']['ios']['universal_link']
    if app_id.nil?
        system("ruby #{current_dir}/wechat_setup.rb -u #{universal_link} -p #{project_dir} -n Runner.xcodeproj")
    else
        system("ruby #{current_dir}/wechat_setup.rb -a #{app_id} -u #{universal_link} -p #{project_dir} -n Runner.xcodeproj")
    end
else
    abort("required values:[auniversal_link] are missing. Please add them in pubspec.yaml:\ncasdoor_flutter_sdk:\n \nios:\nuniversal_link: https://${applinks domain}/universal_link/${example_app}/wechat/\n")
end

Pod::Spec.new do |s|
  s.name             = 'casdoor_flutter_sdk'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.static_framework = true
  s.default_subspec = sdk_subspec

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  pod_target_xcconfig = {
     'OTHER_LDFLAGS' => '$(inherited) -ObjC -all_load'
  }

  s.subspec 'pay' do |sp|
    sp.dependency 'WechatOpenSDK-XCFramework','~> 2.0.2'

    pod_target_xcconfig["GCC_PREPROCESSOR_DEFINITIONS"] = "$(inherited) #{logging_status} #{scene_delegate}"

    sp.pod_target_xcconfig = pod_target_xcconfig
  end

  s.subspec 'no_pay' do |sp|
    sp.dependency 'OpenWeChatSDKNoPay','~> 2.0.2+2'
    sp.frameworks = 'CoreGraphics', 'Security', 'WebKit'
    sp.libraries = 'c++', 'z', 'sqlite3.0'
    pod_target_xcconfig["GCC_PREPROCESSOR_DEFINITIONS"] = "$(inherited) NO_PAY=1 #{logging_status} #{scene_delegate}"
    sp.pod_target_xcconfig = pod_target_xcconfig
  end

end
