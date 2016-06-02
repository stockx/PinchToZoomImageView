#
# Be sure to run `pod lib lint PinchableImageView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PinchableImageView"
  s.version          = "0.2.0"
  s.summary          = "You can pinch an imageView."

  s.description      = <<-DESC
You can rotate and scale this imageView by pinching.
                       DESC

  s.homepage         = "https://github.com/malt03/PinchableImageView"
  s.screenshots      = "https://raw.githubusercontent.com/malt03/PinchableImageView/master/Screenshot.gif"
  s.license          = 'MIT'
  s.author           = { "Koji Murata" => "malt.koji@gmail.com" }
  s.source           = { :git => "https://github.com/malt03/PinchableImageView.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
