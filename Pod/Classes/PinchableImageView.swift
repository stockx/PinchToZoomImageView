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
  
  public weak var delegate: PinchableImageViewDelegate?
  
  // MARK: - for lock
  
  public var lockRotate = false
  public var lockScale = false
  public var lockOriginX = false
  public var lockOriginY = false
  
  public func unlockAll() {
    lockRotate = false
    lockScale = false
    lockOriginX = false
    lockOriginY = false
  }
  
  // MARK: - for corner views
  
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
      self.cornerViews[corner] = view
      if panEnabled {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.cornerPanned(_:)))
        view.addGestureRecognizer(pan)
      }
      handler?(addedView: view, corner: corner, pinchableImageView: self)
    }
  }
  
  public func showCornerViews() {
    for (corner, view) in cornerViews {
      setCornerImageViewPoint(view, corner: corner)
      superview?.insertSubview(view, aboveSubview: self)
    }
  }
  
  public func hideCornerViews() {
    for (_, view) in cornerViews {
      view.removeFromSuperview()
    }
  }
  
  // MARK: - initial methods
  
  convenience public init() {
    self.init(frame: .zero)
  }
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    userInteractionEnabled = true
    multipleTouchEnabled = true
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - private variables

  // MARK: for panning self view
  private var activeTouches = [UITouch]()
  
  // MARK: for main
  private var beginSize: CGSize!
  private var beginCenter: CGPoint!
  private var beginDistance = CGFloat(0)
  private var beginRadian = CGFloat(0)
  private var beginTransform = CGAffineTransformIdentity
  private var lastRotateTransform = CGAffineTransformIdentity
  private var lastScale = CGFloat(1)
  private var endRotateTransform = CGAffineTransformIdentity
  
  private var activeLocations = [NSObject: CGPoint]()
  private var activeLocationKeys = [NSObject]()
  
  // MARK: for panning corner views
  private var cornerViews = [Corner: UIView]()
  
  private var beginPanRotate = CGFloat(0)
  private var panPointAdjustment = CGPoint.zero
  private var panningRecognizer: UIPanGestureRecognizer?
  
  private var positioning = CGPoint.zero
}

// MARK: - panning corner views

extension PinchableImageView {
  @objc private func cornerPanned(recognizer: UIPanGestureRecognizer) {
    if panningRecognizer == nil {
      panningRecognizer = recognizer
    } else if panningRecognizer != recognizer { return }

    let cornerKey = "corner"
    let centerKey = "center"
    
    var corner: Corner?
    for (c, v) in cornerViews {
      if recognizer.view == v { corner = c }
    }
    guard let c = corner else { return }
    
    let panPointInSuperview = recognizer.locationInView(superview)
    switch recognizer.state {
    case .Began:
      if activeLocations[cornerKey] != nil || activeLocations[centerKey] != nil { return }

      setCornerViewsUserInteractionEnabled(false, withoutCorners: [c])
      
      let point = convertPoint(cornerPoint(c, isPositioning: false), toView: superview)
      let centerPoint = convertPoint(CGPoint(x: bounds.width / 2, y: bounds.height / 2), toView: superview)
      panPointAdjustment = panPointInSuperview - point
      activeLocations[cornerKey] = point
      activeLocations[centerKey] = centerPoint

      touchesBegan([cornerKey, centerKey])

      let diff = panPointInSuperview - centerPoint
      beginPanRotate = atan2(diff.x, diff.y)
    case .Changed:
      if activeLocations[cornerKey] == nil || activeLocations[centerKey] == nil { return }
      let centerPoint = activeLocations[centerKey]!
      let diff = panPointInSuperview - centerPoint
      let panRotate = atan2(diff.x, diff.y)
      activeLocations[cornerKey] = panPointInSuperview - CGPointApplyAffineTransform(panPointAdjustment, CGAffineTransformMakeRotation(beginPanRotate - panRotate))
      touchesMoved()
    case .Ended, .Cancelled:
      if activeLocations[cornerKey] == nil || activeLocations[centerKey] == nil { return }
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
      imageView.transform = CGAffineTransformConcat(beginTransform, lastRotateTransform)
    }
  }
  
  private func setCornerImageViewPoint(view: UIView, corner: Corner) {
    view.center = convertPoint(cornerPoint(corner, isPositioning: true), toView: superview)
  }
  
  private func cornerPoint(corner: Corner, isPositioning: Bool) -> CGPoint {
    let point: CGPoint
    let applyPositioning = isPositioning ? positioning / lastScale : .zero
    switch corner {
    case .LeftTop:     return CGPoint(x: applyPositioning.x,                y: applyPositioning.y)
    case .RightTop:    return CGPoint(x: bounds.width - applyPositioning.x, y: applyPositioning.y)
    case .LeftBottom:  return CGPoint(x: applyPositioning.x,                y: bounds.height - applyPositioning.y)
    case .RightBottom: return CGPoint(x: bounds.width - applyPositioning.x, y: bounds.height - applyPositioning.y)
    }
  }
  
  private func setCornerViewsUserInteractionEnabled(enabled: Bool, withoutCorners: [Corner]) {
    for (corner, view) in cornerViews {
      if !withoutCorners.contains(corner) {
        view.userInteractionEnabled = enabled
      }
    }
  }
}

// MARK: - panning self view

extension PinchableImageView {
  override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    setCornerViewsUserInteractionEnabled(false, withoutCorners: [])

    var keys = [UITouch]()
    for t in touches {
      activeTouches.append(t)
      activeLocations[t] = t.locationInView(superview)
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
  
  public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    guard let t = touches else { return }
    touchesEnded(t, withEvent: event)
  }
}

// MARK: - main
extension PinchableImageView {
  private func activeLocation(index: Int) -> CGPoint {
    return activeLocations[activeLocationKeys[index]]!
  }
  private func updateActiveLocationsFromTouches() {
    for t in activeTouches {
      activeLocations[t] = t.locationInView(superview)
    }
  }

  private func touchesBegan(keys: [NSObject]) {
    let lastActiveTouchesCount = activeLocationKeys.count
    activeLocationKeys += keys
    
    let transform = CGAffineTransformTranslateWithSize(self.transform, -bounds.size / 2)
    let location0 = CGPointApplyAffineTransform(convertPoint(activeLocation(0), fromView: superview), transform)
    
    beginSize = bounds.size
    beginTransform = endRotateTransform
    lastRotateTransform = CGAffineTransformIdentity
    lastScale = 1
    
    if activeLocationKeys.count == 1 {
      beginCenter = location0
    } else if lastActiveTouchesCount < 2 && activeLocationKeys.count >= 2 {
      let location1 = CGPointApplyAffineTransform(convertPoint(activeLocation(1), fromView: superview), transform)
      (beginDistance, beginRadian, beginCenter) = distanceRadianAndCenter(location0, location1)
    }
  }
  
  private func touchesMoved() {
    let location0 = activeLocation(0)
    let c: CGPoint
    if activeLocationKeys.count == 1 {
      c = location0 - beginCenter
    } else {
      let location1 = activeLocation(1)
      let (distance, radian, location) = distanceRadianAndCenter(location0, location1)
      let scale = lockScale ? 1 : distance / beginDistance
      
      let rotate = lockRotate ? 0 : beginRadian - radian
      let locationInLabelFromCenter = beginCenter * scale
      
      lastScale = scale
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
      beginSize = bounds.size
      lastScale = 1
      
      self.transform = endRotateTransform
      
      if activeLocationKeys.count == 1 {
        updateActiveLocationsFromTouches()
        let transform = CGAffineTransformTranslateWithSize(self.transform, -bounds.size / 2)
        beginCenter = CGPointApplyAffineTransform(convertPoint(activeLocation(0), fromView: superview), transform)
      } else {
        setCornerViewsUserInteractionEnabled(true, withoutCorners: [])
      }
    }
  }
}

// MARK: - expand tap territory

extension PinchableImageView {
  override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    if activeLocationKeys.count > 0 { return true }
    var rect = bounds
    rect.origin.x += tappableInset.left
    rect.origin.y += tappableInset.top
    rect.size.width -= (tappableInset.left + tappableInset.right)
    rect.size.height -= (tappableInset.top + tappableInset.bottom)
    return CGRectContainsPoint(rect, point)
  }
}

// MARK: - util

private func distanceRadianAndCenter(a: CGPoint, _ b: CGPoint) -> (CGFloat, CGFloat, CGPoint!) {
  let diff = a - b
  let distance = sqrt(diff.x * diff.x + diff.y * diff.y)
  let radian = atan2(diff.x, diff.y)
  let center = (a + b) / 2
  return (distance, radian, center)
}

// MARK: - creating transform

private func CGAffineTransformTranslateWithSize(transform: CGAffineTransform, _ size: CGSize) -> CGAffineTransform {
  return CGAffineTransformTranslate(transform, size.width, size.height)
}

private func CGAffineTransformScaleWithFloat(transform: CGAffineTransform, _ float: CGFloat) -> CGAffineTransform {
  return CGAffineTransformScale(transform, float, float)
}

// MARK: - operators

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
