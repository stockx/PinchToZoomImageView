//
//  ViewController.swift
//  PinchableImageView
//
//  Created by Koji Murata on 04/06/2016.
//  Copyright (c) 2016 Koji Murata. All rights reserved.
//

import UIKit
import PinchableImageView

class ViewController: UIViewController, PinchableImageViewDelegate {
  private let imageView = PinchableImageView()
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    imageView.image = UIImage(named: "lena")!
    imageView.sizeToFit()
    imageView.center = view.center
    func v() -> UIView {
      let iview = UIImageView(image: UIImage(named: "arrow")!)
      iview.frame.size = CGSize(width: 40, height: 40)
      return iview
    }
    let removeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    removeButton.backgroundColor = .redColor()
    removeButton.addTarget(self, action: #selector(remove), forControlEvents: .TouchUpInside)
    
    imageView.addCornerViews([.LeftBottom: v(), .RightTop: v(), .RightBottom: v()], positioning: CGPoint(x: -10, y: -10))
    imageView.addCornerViews([.LeftTop: removeButton], positioning: .zero, panEnabled: false)
    
    imageView.delegate = self
    
    view.addSubview(imageView)
  }
  
  @objc private func remove() {
    imageView.removeFromSuperview()
  }
  
  @IBAction func touchDownBackground() {
    imageView.hideCornerViews()
  }

  func pinchableImageViewTouchesBegan(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {
    pinchableImageView.showCornerViews()
  }

  func pinchableImageViewTouchesMoved(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {

  }

  func pinchableImageViewTouchesEnded(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {

  }
}

