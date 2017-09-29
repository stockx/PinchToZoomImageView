![PincToZoom Logo](https://cloud.githubusercontent.com/assets/879038/25967075/ee645970-365a-11e7-9023-80aef07d25a2.jpg)

![Swift3.1](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat")
[![Platform](https://img.shields.io/cocoapods/p/PinchToZoomImageView.svg?style=flat)](http://cocoapods.org/pods/PinchToZoomImageView)
[![Version](https://img.shields.io/cocoapods/v/PinchToZoomImageView.svg?style=flat)](http://cocoapods.org/pods/PinchToZoomImageView)
[![License](https://img.shields.io/cocoapods/l/PinchToZoomImageView.svg?style=flat)](http://cocoapods.org/pods/PinchToZoomImageView)

Description
--------------

`PinchToZoomImageView` is a drop-in replacement for `UIImageView` that supports pinching, panning, and rotating. Use cases include any occurences of an image that is zoomable. This was inspired by [InstaZoom](https://github.com/paulemmanuel-garcia/InstaZoom) and [ZoomRotatePanImageView](https://github.com/bennythemink/ZoomRotatePanImageView).

![pinch-to-zoom-image-view](https://cloud.githubusercontent.com/assets/879038/26073881/162a8454-397e-11e7-96d7-aca5d5b75d25.gif)

# Contents
1. [Features](#features)
3. [Installation](#installation)
4. [Supported OS & SDK versions](#supported-versions)
5. [Usage](#usage)
6. [License](#license)
7. [Contact](#contact)

<a name="features"> Features </a>
--------------

- [x] Supports pinching, panning, and rotating.
- [x] Works when used in a `UIViewController` or `UIScrollVieController` (e.g. `UICollectionViewController`, `UITableViewController`, etc.).
- [x] Shows the pinched image overtop everythingls else on the screen, with the exception of the status bar.
- [x] Fully configurable in Interface Builder and code.
- [x] Example app to demonstrate the various configurations.

<a name="installation"> Installation </a>
--------------

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `PinchToZoomImageView` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'PinchToZoomImageView'
```

Then, run the following command:

```bash
$ pod install
```

In case Xcode complains (<i>"Cannot load underlying module for PinchToZoomImageView"</i>) go to Product and choose Clean (or simply press <kbd>⇧</kbd><kbd>⌘</kbd><kbd>K</kbd>).

### Manually

If you prefer not to use CocoaPods, you can integrate `PinchToZoomImageView` into your project manually.

<a name="supported-versions"> Supported OS & SDK Versions </a>
-----------------------------

* Supported build target - iOS 8.2+ (Xcode 8.3.2+)

<a name="usage"> Usage </a>
--------------

`PinchToZoomImageView` is a subclass of `UIImageView`. Use `PinchToZoomImageView` just as you would a normal `UIImageView`.

`PinchToZoomImageView` can be used in either Interface Builder or code. In order to enable/disable pinching, update the `isPinchable` property.

<a name="license"> License </a>
--------------

`PinchToZoomImageView` is developed by [Josh Sklar](https://www.linkedin.com/in/jrmsklar) at [StockX](https://stockx.com) and is released under the MIT license. See the `LICENSE` file for details.

<a name="contact"> Contact </a>
--------------

You can follow or drop me a line on [my Twitter account](https://twitter.com/jrmsklar). If you find any issues on the project, you can open a ticket. Pull requests are also welcome.
