Pod::Spec.new do |s|
  s.name         = 'UXKit'
  s.version      = '0.3.6'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     = 'https://github.com/conmulligan/UXKit'
  s.author       = { "Conor Mulligan" => "conmulligan@gmail.com" }
  s.summary      = 'UXKit is a collection of utility classes designed to supplement UIKit.'
  s.source       = { :git => "http://github.com/conmulligan/UXKit.git", :tag => s.version.to_s  }
  s.source_files = 'UXKit/*.{h,m}'
  s.resource_bundles = { 'UXKit' => ['Resources/*'] }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
end
