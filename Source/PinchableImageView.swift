//
//  PinchableImageView.swift
//  PinchableImageView
//
//  Created by Josh Sklar on 5/9/17.
//  Copyright © 2017 StockX. All rights reserved.
//

import UIKit

public class PinchableImageView: UIImageView {

    fileprivate var pinchGestureRecognizer: UIPinchGestureRecognizer?
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?

    public var isPinchable = true {
        didSet {
            isUserInteractionEnabled = isPinchable
            pinchGestureRecognizer?.isEnabled = isPinchable
        }
    }
    
    private var scale: CGFloat = 1.0
    
    // MARK: Init
    
    private func commonInit() {
        isUserInteractionEnabled = true
        
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinchImage(_:)))
        pinchGestureRecognizer?.delegate = self
        addGestureRecognizer(pinchGestureRecognizer!)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanImage(_:)))
        panGestureRecognizer?.delegate = self
        panGestureRecognizer?.minimumNumberOfTouches = 2
        panGestureRecognizer?.maximumNumberOfTouches = 2
        addGestureRecognizer(panGestureRecognizer!)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Helper
    
    fileprivate func reset() {
        print("resetting")
        scale = 1.0
        UIView.animate(withDuration: 2) {
            self.layer.transform = CATransform3DIdentity
        }
    }

    @objc private func didPinchImage(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.scale >= 1.0 {
            scale = recognizer.scale
            transform(withTranslation: .zero)
        }

        if recognizer.state == .ended {
            reset()
        }
    }
    
    @objc private func didPanImage(_ recognizer: UIPanGestureRecognizer) {
        if scale > 1.0 {
            transform(withTranslation: recognizer.translation(in: self))
        }
    
        if recognizer.state == .ended {
            reset()
        }
    }
    
    /** 
     Will transform the image with the
     appropriate scale or translation.
    */
    private func transform(withTranslation translation: CGPoint) {
        print("transforming!")
        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, scale, scale, 1.01)
        transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
        layer.transform = transform
    }
}

extension PinchableImageView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
