Pod::Spec.new do |s|
  s.name             = "Datavenue"
  s.version          = "0.1.0"
  s.summary          = "Library to access the Datavenue API"
  s.homepage         = "http://datavenue.orange.com"
  s.license          = {:type => 'Apache V2.0', :file =>'LICENSE'}
  s.author           = { "Marc Capdevielle" => "marc.capdevielle@orange.com" }
  s.source           = { :git => "https://github.com/Orange-Datavenue/Datavenue-iOS-SDK.git", :tag => s.version.to_s }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'Classes/**/*{h,m}'
end
