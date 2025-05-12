# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CHRGUP' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CHRGUP
pod 'Google-Maps-iOS-Utils'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    end
  end
end

end
