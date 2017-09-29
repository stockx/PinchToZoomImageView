Pod::Spec.new do |s|
  s.name                    = 'PinchToZoomImageView'
  s.version                 = '1.1.1'
  s.summary                 = 'PinchToZoomImageView is a drop-in replacement for UIImageView that supports pinching, panning, and rotating.'
  s.homepage                = 'https://github.com/stockx/PinchToZoomImageView'
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }
  s.author                  = { 'Josh Sklar' => 'jrmsklar@gmail.com' }
  s.social_media_url        = 'https://twitter.com/jrmsklar'
  s.ios.deployment_target   = '8.2'
  s.source                  = { :git => 'https://github.com/StockX/PinchToZoomImageView.git', :tag => s.version.to_s }
  s.source_files            = 'Source/**/*.swift'
  s.description             = <<-DESC
PinchToZoomImageView is a drop-in replacement for UIImageView that supports pinching, panning, and rotating. Use cases include any occurences of an image that is zoomable.

Features:
- Supports pinching, panning, and rotating.
- Works when used in a UIViewController or UIScrollVieController (e.g. UICollectionViewController, UITableViewController, etc.).
- Shows the pinched image overtop everythingls else on the screen, with the exception of the status bar.
- Fully configurable in Interface Builder and code.
- Example app to demonstrate the various configurations.
                              DESC
end
