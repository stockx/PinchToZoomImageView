//
//  PinchableImageView.swift
//  PinchAndRotate
//
//  Created by Koji Murata on 2016/02/09.
//  Copyright © 2016年 Koji Murata. All rights reserved.
//

import UIKit

@objc public protocol PinchableImageViewDelegate {
  @objc optional func pinchableImageViewTouchesBegan(_ pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?)
  @objc optional func pinchableImageViewTouchesMoved(_ pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?)
  @objc optional func pinchableImageViewTouchesEnded(_ pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?)
}

open class PinchableImageView: UIImageView {
  // Making the hit area larger than the default hit area.
  open var tappableInset = UIEdgeInsets(top: -50, left: -50, bottom: -50, right: -50)
  
  open weak var delegate: PinchableImageViewDelegate?
  
  // MARK: - for lock
  
  open var lockRotate = false
  open var lockScale = false
  open var lockOriginX = false
  open var lockOriginY = false
  
  open func unlockAll() {
    lockRotate = false
    lockScale = false
    lockOriginX = false
    lockOriginY = false
  }
  
  // MARK: - for corner views
  
  public enum Corner {
    case leftTop
    case rightTop
    case leftBottom
    case rightBottom
  }
  
  open func addCornerViews(_ cornerViews: [Corner: UIView], positioning p: CGPoint = .zero, panEnabled: Bool = true, handler: ((_ addedView: UIView, _ corner: Corner, _ pinchableImageView: PinchableImageView) -> Void)? = nil) {
    positioning = p
    for (corner, view) in cornerViews {
      self.cornerViews[corner]?.removeFromSuperview()
      view.isUserInteractionEnabled = true
      self.cornerViews[corner] = view
      if panEnabled {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.cornerPanned(_:)))
        view.addGestureRecognizer(pan)
      }
      handler?(view, corner, self)
    }
  }
  
  open func showCornerViews() {
    for (corner, view) in cornerViews {
      setCornerImageViewPoint(view, corner: corner)
      superview?.insertSubview(view, aboveSubview: self)
    }
  }
  
  open func hideCornerViews() {
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
    isUserInteractionEnabled = true
    isMultipleTouchEnabled = true
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - private variables

  // MARK: for panning self view
  fileprivate var activeTouches = [UITouch]()
  
  // MARK: for main
  fileprivate var beginSize: CGSize!
  fileprivate var beginCenter: CGPoint!
  fileprivate var beginDistance = CGFloat(0)
  fileprivate var beginRadian = CGFloat(0)
  fileprivate var beginTransform = CGAffineTransform.identity
  fileprivate var lastRotateTransform = CGAffineTransform.identity
  fileprivate var lastScale = CGFloat(1)
  fileprivate var endRotateTransform = CGAffineTransform.identity
  
  fileprivate var activeLocations = [NSObject: CGPoint]()
  fileprivate var activeLocationKeys = [NSObject]()
  
  // MARK: for panning corner views
  fileprivate var cornerViews = [Corner: UIView]()
  
  fileprivate var beginPanRotate = CGFloat(0)
  fileprivate var panPointAdjustment = CGPoint.zero
  fileprivate var panningRecognizer: UIPanGestureRecognizer?
  
  fileprivate var positioning = CGPoint.zero
}

// MARK: - panning corner views

extension PinchableImageView {
  @objc fileprivate func cornerPanned(_ recognizer: UIPanGestureRecognizer) {
    if panningRecognizer == nil {
      panningRecognizer = recognizer
    } else if panningRecognizer != recognizer { return }

    let cornerKey = "corner" as NSString
    let centerKey = "center" as NSString
    
    var corner: Corner?
    for (c, v) in cornerViews {
      if recognizer.view == v { corner = c }
    }
    guard let c = corner else { return }
    
    let panPointInSuperview = recognizer.location(in: superview)
    switch recognizer.state {
    case .began:
      if activeLocations[cornerKey] != nil || activeLocations[centerKey] != nil { return }

      setCornerViewsUserInteractionEnabled(false, withoutCorners: [c])
      
      let point = convert(cornerPoint(c, isPositioning: false), to: superview)
      let centerPoint = convert(CGPoint(x: bounds.width / 2, y: bounds.height / 2), to: superview)
      panPointAdjustment = panPointInSuperview - point
      activeLocations[cornerKey] = point
      activeLocations[centerKey] = centerPoint

      touchesBegan([cornerKey as NSObject, centerKey as NSObject])

      let diff = panPointInSuperview - centerPoint
      beginPanRotate = atan2(diff.x, diff.y)
    case .changed:
      if activeLocations[cornerKey] == nil || activeLocations[centerKey] == nil { return }
      let centerPoint = activeLocations[centerKey]!
      let diff = panPointInSuperview - centerPoint
      let panRotate = atan2(diff.x, diff.y)
      activeLocations[cornerKey] = panPointInSuperview - panPointAdjustment.applying(CGAffineTransform(rotationAngle: beginPanRotate - panRotate))
      touchesMoved()
    case .ended, .cancelled:
      if activeLocations[cornerKey] == nil || activeLocations[centerKey] == nil { return }
      activeLocations.removeValue(forKey: cornerKey)
      activeLocations.removeValue(forKey: centerKey)
      touchesEnded([cornerKey as NSObject, centerKey as NSObject])
      panningRecognizer = nil
    default:
      break
    }
  }
  
  fileprivate func updateImageViewsPointAndRotate() {
    for (corner, imageView) in cornerViews {
      setCornerImageViewPoint(imageView, corner: corner)
      imageView.transform = beginTransform.concatenating(lastRotateTransform)
    }
  }
  
  fileprivate func setCornerImageViewPoint(_ view: UIView, corner: Corner) {
    view.center = convert(cornerPoint(corner, isPositioning: true), to: superview)
  }
  
  fileprivate func cornerPoint(_ corner: Corner, isPositioning: Bool) -> CGPoint {
    let applyPositioning = isPositioning ? positioning / lastScale : .zero
    switch corner {
    case .leftTop:     return CGPoint(x: applyPositioning.x,                y: applyPositioning.y)
    case .rightTop:    return CGPoint(x: bounds.width - applyPositioning.x, y: applyPositioning.y)
    case .leftBottom:  return CGPoint(x: applyPositioning.x,                y: bounds.height - applyPositioning.y)
    case .rightBottom: return CGPoint(x: bounds.width - applyPositioning.x, y: bounds.height - applyPositioning.y)
    }
  }
  
  fileprivate func setCornerViewsUserInteractionEnabled(_ enabled: Bool, withoutCorners: [Corner]) {
    for (corner, view) in cornerViews {
      if !withoutCorners.contains(corner) {
        view.isUserInteractionEnabled = enabled
      }
    }
  }
}

// MARK: - panning self view

extension PinchableImageView {
  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    setCornerViewsUserInteractionEnabled(false, withoutCorners: [])

    var keys = [UITouch]()
    for t in touches {
      activeTouches.append(t)
      activeLocations[t] = t.location(in: superview)
      keys.append(t)
    }

    touchesBegan(keys)
    delegate?.pinchableImageViewTouchesBegan?(self, touches: touches, withEvent: event)
  }
  
  override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    updateActiveLocationsFromTouches()

    touchesMoved()
    
    delegate?.pinchableImageViewTouchesMoved?(self, touches: touches, withEvent: event)
  }
  
  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {
      activeLocations.removeValue(forKey: t)
      activeTouches.remove(at: activeTouches.index(of: t)!)
    }
    
    touchesEnded(touches)
    
    delegate?.pinchableImageViewTouchesEnded?(self, touches: touches, withEvent: event)
  }
  
  open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchesEnded(touches, with: event)
  }
}

// MARK: - main
extension PinchableImageView {
  fileprivate func activeLocation(_ index: Int) -> CGPoint {
    return activeLocations[activeLocationKeys[index]]!
  }
  fileprivate func updateActiveLocationsFromTouches() {
    for t in activeTouches {
      activeLocations[t] = t.location(in: superview)
    }
  }

  fileprivate func touchesBegan(_ keys: [NSObject]) {
    let lastActiveTouchesCount = activeLocationKeys.count
    activeLocationKeys += keys
    
    let transform = CGAffineTransformTranslateWithSize(self.transform, -bounds.size / 2)
    let location0 = convert(activeLocation(0), from: superview).applying(transform)
    
    beginSize = bounds.size
    beginTransform = endRotateTransform
    lastRotateTransform = CGAffineTransform.identity
    lastScale = 1
    
    if activeLocationKeys.count == 1 {
      beginCenter = location0
    } else if lastActiveTouchesCount < 2 && activeLocationKeys.count >= 2 {
      let location1 = convert(activeLocation(1), from: superview).applying(transform)
      var center: CGPoint?
      (beginDistance, beginRadian, center) = distanceRadianAndCenter(location0, location1)
      beginCenter = center
    }
  }
  
  fileprivate func touchesMoved() {
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
      lastRotateTransform = CGAffineTransform(rotationAngle: rotate)
      let transform = CGAffineTransformScaleWithFloat(lastRotateTransform, lastScale)
      self.transform = beginTransform.concatenating(transform)
      c = location! - locationInLabelFromCenter.applying(lastRotateTransform)
    }
    
    if !lockOriginX { center.x = c.x }
    if !lockOriginY { center.y = c.y }
    
    updateImageViewsPointAndRotate()
  }
  
  fileprivate func touchesEnded(_ keys: Set<NSObject>) {
    for k in keys {
      activeLocationKeys.remove(at: activeLocationKeys.index(of: k)!)
    }
    if activeLocationKeys.count < 2 {
      endRotateTransform = beginTransform.concatenating(lastRotateTransform)
      
      bounds.size = beginSize * lastScale
      beginSize = bounds.size
      lastScale = 1
      
      self.transform = endRotateTransform
      
      if activeLocationKeys.count == 1 {
        updateActiveLocationsFromTouches()
        let transform = CGAffineTransformTranslateWithSize(self.transform, -bounds.size / 2)
        beginCenter = convert(activeLocation(0), from: superview).applying(transform)
      } else {
        setCornerViewsUserInteractionEnabled(true, withoutCorners: [])
      }
    }
  }
}

// MARK: - expand tap territory

extension PinchableImageView {
  override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if activeLocationKeys.count > 0 { return true }
    var rect = bounds
    rect.origin.x += tappableInset.left
    rect.origin.y += tappableInset.top
    rect.size.width -= (tappableInset.left + tappableInset.right)
    rect.size.height -= (tappableInset.top + tappableInset.bottom)
    return rect.contains(point)
  }
}

// MARK: - for subviews

extension PinchableImageView {
  open override func removeFromSuperview() {
    super.removeFromSuperview()
    for (_, view) in cornerViews {
      view.removeFromSuperview()
    }
  }
}

// MARK: - util

private func distanceRadianAndCenter(_ a: CGPoint, _ b: CGPoint) -> (CGFloat, CGFloat, CGPoint?) {
  let diff = a - b
  let distance = sqrt(diff.x * diff.x + diff.y * diff.y)
  let radian = atan2(diff.x, diff.y)
  let center = (a + b) / 2
  return (distance, radian, center)
}

// MARK: - creating transform

private func CGAffineTransformTranslateWithSize(_ transform: CGAffineTransform, _ size: CGSize) -> CGAffineTransform {
  return transform.translatedBy(x: size.width, y: size.height)
}

private func CGAffineTransformScaleWithFloat(_ transform: CGAffineTransform, _ float: CGFloat) -> CGAffineTransform {
  return transform.scaledBy(x: float, y: float)
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
