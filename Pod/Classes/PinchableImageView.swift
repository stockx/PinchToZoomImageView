//
//  PinchableImageView.swift
//  PinchAndRotate
//
//  Created by Koji Murata on 2016/02/09.
//  Copyright © 2016年 Koji Murata. All rights reserved.
//

import UIKit

@objc public protocol PinchableImageViewDelegate {
  optional func pinchableImageViewTouchesBegan(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?)
  optional func pinchableImageViewTouchesMoved(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?)
  optional func pinchableImageViewTouchesEnded(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?)
}

public class PinchableImageView: UIImageView {
  // Making the hit area larger than the default hit area.
  public var tappableInset = UIEdgeInsets(top: -50, left: -50, bottom: -50, right: -50)
  
  public var lockRotate = false
  public var lockScale = false
  public var lockOriginX = false
  public var lockOriginY = false
  
  public weak var delegate: PinchableImageViewDelegate?
  
  convenience public init() {
    self.init(frame: .zero)
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    userInteractionEnabled = true
    multipleTouchEnabled = true
  }
  
  public enum Corner {
    case LeftTop
    case RightTop
    case LeftBottom
    case RightBottom
  }
  
  public func addCornerViews(cornerViews: [Corner: UIView], positioning p: CGPoint = .zero, panEnabled: Bool = true, handler: ((addedView: UIView, corner: Corner, pinchableImageView: PinchableImageView) -> Void)? = nil) {
    positioning = p
    for (corner, view) in cornerViews {
      view.userInteractionEnabled = true
      setCornerImageViewPoint(view, corner: corner)
      superview?.insertSubview(view, aboveSubview: self)
      self.cornerViews[corner] = view
      if panEnabled {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.cornerPanned(_:)))
        view.addGestureRecognizer(pan)
      }
      handler?(addedView: view, corner: corner, pinchableImageView: self)
    }
  }
  
  @objc private func cornerPanned(recognizer: UIPanGestureRecognizer) {
    let cornerKey = "corner"
    let centerKey = "center"
    activeLocations[cornerKey] = recognizer.locationInView(self)

    switch recognizer.state {
    case .Began:
      activeLocations[centerKey] = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
      touchesBegan([cornerKey, centerKey])
    case .Changed:
      touchesMoved()
    case .Ended, .Cancelled:
      activeLocations.removeValueForKey(cornerKey)
      activeLocations.removeValueForKey(centerKey)
      touchesEnded([cornerKey, centerKey])
    default:
      break
    }
  }
  
  private func updateImageViewsPointAndRotate() {
    for (corner, imageView) in cornerViews {
      setCornerImageViewPoint(imageView, corner: corner)
      imageView.transform = lastRotateTransform
    }
  }
  
  private var positioning = CGPoint.zero
  
  private func setCornerImageViewPoint(view: UIView, corner: Corner) {
    let point: CGPoint
    switch corner {
    case .LeftTop:     point = CGPoint(x: positioning.x,                y: positioning.y)
    case .RightTop:    point = CGPoint(x: bounds.width - positioning.x, y: positioning.y)
    case .LeftBottom:  point = CGPoint(x: positioning.x,                y: bounds.height - positioning.y)
    case .RightBottom: point = CGPoint(x: bounds.width - positioning.x, y: bounds.height - positioning.y)
    }
    view.center = convertPoint(point, toView: superview)
  }
  
  private var cornerViews = [Corner: UIView]()
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func unlockAll() {
    lockRotate = false
    lockScale = false
    lockOriginX = false
    lockOriginY = false
  }
  
  private var beginSize: CGSize!
  private var beginCenter: CGPoint!
  private var beginDistance = CGFloat(0)
  private var beginRadian = CGFloat(0)
  private var beginTransform = CGAffineTransformIdentity
  private var lastRotateTransform = CGAffineTransformIdentity
  private var lastScale = CGFloat(1)
  private var endRotateTransform = CGAffineTransformIdentity
  private var endScale = CGFloat(1)
  
  private var activeTouches = [UITouch]()
  
  private var activeLocations = [NSObject: CGPoint]()
  private var activeLocationKeys = [NSObject]()
  private func activeLocation(index: Int) -> CGPoint {
    return activeLocations[activeLocationKeys[index]]!
  }
  private func updateActiveLocationsFromTouches() {
    for t in activeTouches {
      activeLocations[t] = t.locationInView(self)
    }
  }
  
  override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    var keys = [UITouch]()
    for t in touches {
      activeTouches.append(t)
      activeLocations[t] = t.locationInView(self)
      keys.append(t)
    }

    touchesBegan(keys)
    delegate?.pinchableImageViewTouchesBegan?(self, touches: touches, withEvent: event)
  }
  
  override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    updateActiveLocationsFromTouches()

    touchesMoved()
    
    delegate?.pinchableImageViewTouchesMoved?(self, touches: touches, withEvent: event)
  }
  
  override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for t in touches {
      activeLocations.removeValueForKey(t)
      activeTouches.removeAtIndex(activeTouches.indexOf(t)!)
    }
    
    touchesEnded(touches)
    
    delegate?.pinchableImageViewTouchesEnded?(self, touches: touches, withEvent: event)
  }
  
  private func touchesBegan(keys: [NSObject]) {
    let lastActiveTouchesCount = activeLocationKeys.count
    activeLocationKeys += keys
    
    let transform = CGAffineTransformTranslateWithSize(self.transform, -bounds.size / 2)
    let location0 = CGPointApplyAffineTransform(activeLocation(0), transform)
    
    beginSize = bounds.size
    beginTransform = endRotateTransform
    lastRotateTransform = CGAffineTransformIdentity
    lastScale = endScale
    
    if activeLocationKeys.count == 1 {
      beginCenter = location0
    } else if lastActiveTouchesCount < 2 && activeLocationKeys.count >= 2 {
      let location1 = CGPointApplyAffineTransform(activeLocation(1), transform)
      (beginDistance, beginRadian, beginCenter) = distanceRadianAndCenter(location0, location1)
    }
  }
  
  private func touchesMoved() {
    let location0 = convertPoint(activeLocation(0), toView: superview)
    let c: CGPoint
    if activeLocationKeys.count == 1 {
      c = location0 - beginCenter
    } else {
      let location1 = convertPoint(activeLocation(1), toView: superview)
      let (distance, radian, location) = distanceRadianAndCenter(location0, location1)
      let scale = lockScale ? 1 : distance / beginDistance
      
      let rotate = lockRotate ? 0 : beginRadian - radian
      let locationInLabelFromCenter = beginCenter * scale
      
      lastScale = scale * endScale
      lastRotateTransform = CGAffineTransformMakeRotation(rotate)
      let transform = CGAffineTransformScaleWithFloat(lastRotateTransform, lastScale)
      self.transform = CGAffineTransformConcat(beginTransform, transform)
      c = location - CGPointApplyAffineTransform(locationInLabelFromCenter, lastRotateTransform)
    }
    
    if !lockOriginX { center.x = c.x }
    if !lockOriginY { center.y = c.y }
    
    updateImageViewsPointAndRotate()
  }
  
  private func touchesEnded(keys: Set<NSObject>) {
    for k in keys {
      activeLocationKeys.removeAtIndex(activeLocationKeys.indexOf(k)!)
    }
    if activeLocationKeys.count < 2 {
      endRotateTransform = CGAffineTransformConcat(beginTransform, lastRotateTransform)
      
      bounds.size = beginSize * lastScale
      
      endScale = 1
      self.transform = endRotateTransform
      
      if activeLocationKeys.count == 1 {
        updateActiveLocationsFromTouches()
        let transform = CGAffineTransformTranslateWithSize(self.transform, -bounds.size / 2)
        beginCenter = CGPointApplyAffineTransform(activeLocation(0), transform)
      }
    }
  }
  
  public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    guard let t = touches else { return }
    touchesEnded(t, withEvent: event)
  }
  
  override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    if activeLocationKeys.count > 0 { return true }
    var rect = bounds
    rect.origin.x += tappableInset.left / endScale
    rect.origin.y += tappableInset.top / endScale
    rect.size.width -= (tappableInset.left + tappableInset.right) / endScale
    rect.size.height -= (tappableInset.top + tappableInset.bottom) / endScale
    return CGRectContainsPoint(rect, point)
  }
}

private func distanceRadianAndCenter(a: CGPoint, _ b: CGPoint) -> (CGFloat, CGFloat, CGPoint!) {
  let diff = a - b
  let distance = sqrt(diff.x * diff.x + diff.y * diff.y)
  let radian = atan2(diff.x, diff.y)
  let center = (a + b) / 2
  return (distance, radian, center)
}

private func CGAffineTransformTranslateWithSize(transform: CGAffineTransform, _ size: CGSize) -> CGAffineTransform {
  return CGAffineTransformTranslate(transform, size.width, size.height)
}

private func CGAffineTransformScaleWithFloat(transform: CGAffineTransform, _ float: CGFloat) -> CGAffineTransform {
  return CGAffineTransformScale(transform, float, float)
}

private func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

private func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

private func *(left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x * right, y: left.y * right)
}

private func /(left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x / right, y: left.y / right)
}

private func *(left: CGSize, right: CGFloat) -> CGSize {
  return CGSize(width: left.width * right, height: left.height * right)
}

private func /(left: CGSize, right: CGFloat) -> CGSize {
  return CGSize(width: left.width / right, height: left.height / right)
}

private func -(left: CGPoint, right: CGSize) -> CGPoint {
  return CGPoint(x: left.x - right.width, y: left.y - right.height)
}

prefix func -(size: CGSize) -> CGSize {
  return CGSize(width: -size.width, height: -size.height)
}