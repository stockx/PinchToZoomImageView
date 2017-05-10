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
    
    fileprivate var imageViewCopy = UIImageView(frame: .zero)

    public var isPinchable = true {
        didSet {
            isUserInteractionEnabled = isPinchable
            imageViewCopy.isUserInteractionEnabled = isPinchable
            pinchGestureRecognizer?.isEnabled = isPinchable
        }
    }
    
    public override var image: UIImage? {
        didSet {
            imageViewCopy.image = image
        }
    }
    
    public override var contentMode: UIViewContentMode {
        didSet {
            imageViewCopy.contentMode = contentMode
        }
    }
    
    private var scale: CGFloat = 1.0
    
    // MARK: Init
    
    private func commonInit() {
        isUserInteractionEnabled = true
        imageViewCopy.isUserInteractionEnabled = true
        
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinchImage(_:)))
        pinchGestureRecognizer?.delegate = self
        imageViewCopy.addGestureRecognizer(pinchGestureRecognizer!)
        
        imageViewCopy.image = image
        imageViewCopy.contentMode = contentMode
        
        resetImageViewCopyPosition()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Helper - imageViewCopy management
    
    private func resetImageViewCopyPosition() {
        addSubview(imageViewCopy)
        imageViewCopy.translatesAutoresizingMaskIntoConstraints = false
        let views = ["imageView": imageViewCopy]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views))
    }
    
    private func moveImageViewCopyToWindow() {
        let window = UIApplication.shared.keyWindow
        imageViewCopy.translatesAutoresizingMaskIntoConstraints = true
        imageViewCopy.frame = superview?.convert(frame, to: window) ?? .zero
        window?.addSubview(imageViewCopy)
    }
    
    // MARK: Helper
    
    fileprivate func reset() {
        scale = 1.0
        UIView.animate(withDuration: 0.3, animations: { 
            self.imageViewCopy.transform = .identity
        }) { (finished) in
            if finished {
                self.resetImageViewCopyPosition()
            }
        }
    }

    @objc private func didPinchImage(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began {
            moveImageViewCopyToWindow()
        }

        if recognizer.scale >= 1.0 {
            scale = recognizer.scale
            transform(withTranslation: .zero)
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
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: scale, y: scale)
        transform = transform.translatedBy(x: translation.x, y: translation.y)
        imageViewCopy.transform = transform
    }
}

extension PinchableImageView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
