Pod::Spec.new do |s|
  s.name               = "PinchableImageView"
  s.version            = "1.0"
  s.summary            = "A fully pinchable, pannable, and rotatebly UIImageView subclass written in Swift."
  s.homepage           = "https://github.com/stockx/PinchableImageView/"
  s.license            = "MIT"
  s.author             = { "Josh Sklar" => "jrmsklar@gmail.com" }
  s.social_media_url   = "https://instagram.com/jrmsklar"
  s.platform           = :ios
  s.platform           = :ios, "8.2"
  s.source             = { :git => "https://github.com/stockx/PinchableImageView.git", :tag => s.version}
  s.source_files       = "Source/**/*.swift"
end
