Pod::Spec.new do |s|
  s.name         = "UXKit"
  s.version      = "0.1.0"
  s.summary      = "UXKit is a collection of utility classes designed to supplement UIKit."

  s.description  = <<-DESC
                   DESC

  s.homepage     = "http://conormulligan.com/UXKit"

  s.license      = 'MIT'
  # s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }

  s.author       = { "Conor Mulligan" => "conmulligan@gmail.com" }
  
  s.platform     = :ios
  s.platform     = :ios, '5.0'

  s.source       = { :git => "http://github.com/conmulligan/UXKit.git", :tag => "0.0.1" }

  s.source_files  = 'Classes', 'UXKit/**/*.{h,m}'
  
  # s.public_header_files = 'UXKit/**/*.h'
end
