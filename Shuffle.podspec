Pod::Spec.new do |s|
  s.name         = "Shuffle"
  s.version      = "0.0.1"
  s.summary      = "Shuffle is a UI framework for your card swiping needs"
  s.homepage     = "https://github.com/jaunesarmiento/Shuffle"
  s.license      = "MIT"
  s.author             = { "Jaune Sarmiento" => "hawnecarlo@gmail.com" }
  s.source       = { :git => "https://github.com/jaunesarmiento/Shuffle.git", :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files  = "Shuffle/*.swift"
  s.requires_arc = true
end
