project 'RevCity.xcodeproj'

# platform :ios, '9.0'

target 'RevCity' do
  use_frameworks!

  # Pods for RevCity
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'Google/SignIn'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
