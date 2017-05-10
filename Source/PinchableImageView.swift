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
    fileprivate var rotateGestureRecognizer: UIRotationGestureRecognizer?

    fileprivate var imageViewCopy = UIImageView(frame: .zero)
    
    /**
     Internal property to determine if the PinchableImageView is currently
     resetting. Helps to prevent duplicate resets simultaneously.
     */
    fileprivate var isResetting = false

    public var isPinchable = true {
        didSet {
            isUserInteractionEnabled = isPinchable
            imageViewCopy.isUserInteractionEnabled = isPinchable
            imageViewCopy.gestureRecognizers?.forEach { $0.isEnabled = isPinchable }
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
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanImage(_:)))
        panGestureRecognizer?.delegate = self
        imageViewCopy.addGestureRecognizer(panGestureRecognizer!)
        
        rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotateImage(_:)))
        rotateGestureRecognizer?.delegate = self
        imageViewCopy.addGestureRecognizer(rotateGestureRecognizer!)
        
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
        guard !isResetting else {
            return
        }
        
        isResetting = true
        
        scale = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.imageViewCopy.center = self.center
            self.imageViewCopy.transform = .identity
        }) { (finished) in
            self.resetImageViewCopyPosition()
            self.isResetting = false
        }
    }

    @objc private func didPinchImage(_ recognizer: UIPinchGestureRecognizer) {
        guard recognizer.state != .ended else {
            reset()
            return
        }
        
        if recognizer.state == .began {
            moveImageViewCopyToWindow()
        }
        
        let newTransform = recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale) ?? .identity
        
        recognizer.view?.transform = newTransform
        scale = scale * recognizer.scale
        recognizer.scale = 1
    }
    
    @objc private func didPanImage(_ recognizer: UIPanGestureRecognizer) {
        guard scale > 1.0 else {
            return
        }
        
        guard recognizer.state != .ended else {
            reset()
            return
        }
        
        let translation = recognizer.translation(in: imageViewCopy.superview)
        let originalCenter = imageViewCopy.center
        let translatedCenter = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y + translation.y)
        imageViewCopy.center = translatedCenter
        recognizer.setTranslation(.zero, in: imageViewCopy)
    }
    
    @objc private func didRotateImage(_ recognizer: UIRotationGestureRecognizer) {
        guard scale > 1.0 else {
            return
        }
        
        guard recognizer.state != .ended else {
            reset()
            return
        }
        
        recognizer.view?.transform = recognizer.view?.transform.rotated(by: recognizer.rotation) ?? .identity
        recognizer.rotation = 0
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
