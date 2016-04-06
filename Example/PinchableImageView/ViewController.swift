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
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    let imageView = PinchableImageView()

    imageView.image = UIImage(named: "lena")!
    imageView.sizeToFit()
    imageView.center = view.center
    view.addSubview(imageView)
    
    imageView.delegate = self
  }
  
  func pinchableImageViewTouchesBegan(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("began delegate")
  }

  func pinchableImageViewTouchesMoved(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("moved delegate")
  }

  func pinchableImageViewTouchesEnded(pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("ended delegate")
  }
}

