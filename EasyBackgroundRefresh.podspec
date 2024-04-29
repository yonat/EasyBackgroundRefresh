Pod::Spec.new do |s|

  s.name         = 'EasyBackgroundRefresh'
  s.version      = '1.0.4'
  s.summary      = 'Easy background refresh registration, scheduling, execution, and completion. BGTaskScheduler for the lazy.'
  s.homepage     = 'https://github.com/yonat/EasyBackgroundRefresh'
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }

  s.author             = { 'Yonat Sharon' => 'yonat@ootips.org' }

  s.platform     = :ios, '13.0'
  s.swift_versions = ['5.0']

  s.source       = { :git => 'https://github.com/yonat/EasyBackgroundRefresh.git', :tag => s.version }
  s.source_files  = 'Sources/EasyBackgroundRefresh/*.swift'
  s.resource_bundles = {s.name => ['PrivacyInfo.xcprivacy']}

end
