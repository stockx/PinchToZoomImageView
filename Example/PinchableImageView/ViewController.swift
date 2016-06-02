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
    view.addSubview(imageView)
    
    func v() -> UIView {
      let iview = UIImageView(image: UIImage(named: "arrow")!)
      iview.sizeToFit()
      return iview
    }
    imageView.addCornerViews([.LeftBottom: v(), .RightTop: v(), .RightBottom: v()], positioning: CGPoint(x: -10, y: -10))
    
    imageView.delegate = self
  }
  
  @IBAction func touchDownBackground() {
    imageView.hideCornerViews()
  }

  func pinchableImageViewTouchesBegan(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {
    pinchableImageView.showCornerViews()
  }

  func pinchableImageViewTouchesMoved(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("moved delegate")
  }

  func pinchableImageViewTouchesEnded(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("ended delegate")
  }
}

