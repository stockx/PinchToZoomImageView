//
//  PinchableImageView.swift
//  PinchableImageView
//
//  Created by Josh Sklar on 5/9/17.
//  Copyright © 2017 StockX. All rights reserved.
//

import UIKit

public class PinchableImageView: UIImageView {

    fileprivate var imageViewCopy = UIImageView(frame: .zero)

    // MARK: Gesture Recognizers
    
    fileprivate var pinchGestureRecognizer: UIPinchGestureRecognizer?
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    fileprivate var rotateGestureRecognizer: UIRotationGestureRecognizer?
    
    /**
     Internal property to determine if the PinchableImageView is currently
     resetting. Helps to prevent duplicate resets simultaneously.
     */
    fileprivate var isResetting = false

    /**
     Whether or not the image view is pinchable.
     Set this to `false` in order to completely disable pinching/panning/rotating
     functionality.
     Defaults to `true`.
     */
    public var isPinchable = true {
        didSet {
            isUserInteractionEnabled = isPinchable
            imageViewCopy.isUserInteractionEnabled = isPinchable
            imageViewCopy.gestureRecognizers?.forEach { $0.isEnabled = isPinchable }
        }
    }
    
    // MARK: UIImageView overrides

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
    
    // MARK: Pinch management
    
    private var imageViewCopyScale: CGFloat = 1.0 {
        didSet {
            isHidden = imageViewCopyScale > 1.0
        }
    }
    
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
    
    deinit {
        // Make sure that the imageViewCopy is not a subview of the window anymore
        resetImageViewCopyPosition()
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
    
    fileprivate func reset() {
        guard !isResetting else {
            return
        }
        
        isResetting = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.imageViewCopy.center = self?.center ?? .zero
            self?.imageViewCopy.transform = .identity
        }) { [weak self] (finished)in
            self?.resetImageViewCopyPosition()
            self?.isResetting = false
            self?.imageViewCopyScale = 1.0
        }
    }

    // MARK: Gesture Recognizer handlers

    @objc private func didPinchImage(_ recognizer: UIPinchGestureRecognizer) {
        guard recognizer.state != .ended else {
            reset()
            return
        }
        
        if recognizer.state == .began {
            moveImageViewCopyToWindow()
        }
        
        let newScale = imageViewCopyScale * recognizer.scale
        
        // Don't allow pinching to smaller than the original size
        guard newScale > 1.2 else {
            return
        }
        
        imageViewCopyScale = newScale
        
        let newTransform = recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale) ?? .identity
        recognizer.view?.transform = newTransform
        recognizer.scale = 1
    }
    
    @objc private func didPanImage(_ recognizer: UIPanGestureRecognizer) {
        guard imageViewCopyScale > 1.0 else {
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
        guard imageViewCopyScale > 1.0 else {
            return
        }
        
        guard recognizer.state != .ended else {
            reset()
            return
        }
        
        recognizer.view?.transform = recognizer.view?.transform.rotated(by: recognizer.rotation) ?? .identity
        recognizer.rotation = 0
    }
}

extension PinchableImageView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
