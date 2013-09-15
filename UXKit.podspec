Pod::Spec.new do |s|
  s.name         = "UXKit"
  s.version      = "0.1.0"
  s.summary      = "UXKit is a collection of utility classes designed to supplement UIKit."
  s.description  = <<-DESC
                     UXKit is a collection of UIKit utility classes.
                   DESC
                   
  s.homepage     = "http://conormulligan.com/UXKit"
  s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }
  s.author       = { "Conor Mulligan" => "conmulligan@gmail.com" }
  
  s.platform     = :ios, '5.0'
  s.source       = { :git => "http://github.com/conmulligan/UXKit.git", :tag => s.version.to_s  }
  s.source_files  = 'UXKit/*.{h,m}'
  s.requires_arc = true
end
