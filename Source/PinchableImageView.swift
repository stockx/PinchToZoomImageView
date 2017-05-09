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

    public var isPinchable = true {
        didSet {
            isUserInteractionEnabled = isPinchable
            pinchGestureRecognizer?.isEnabled = isPinchable
        }
    }
    
    // MARK: Init
    
    private func commonInit() {
        isUserInteractionEnabled = true
        let gestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinchImage(_:)))
        addGestureRecognizer(gestureRecognizer)
        pinchGestureRecognizer = gestureRecognizer
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// MARK: Helper
    
    fileprivate func reset() {
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }

    @objc private func didPinchImage(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.scale >= 1.0 {
            var transform = CATransform3DIdentity
            transform = CATransform3DScale(transform, recognizer.scale, recognizer.scale, 1.01)
            layer.transform = transform
        }
        
        if recognizer.state == .ended {
            reset()
        }
    }
}


