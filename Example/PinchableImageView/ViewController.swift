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
  fileprivate let imageView = PinchableImageView()
  
  override func viewDidAppear(_ animated: Bool) {
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
    removeButton.backgroundColor = .red
    removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
    
    imageView.addCornerViews([.leftBottom: v(), .rightTop: v(), .rightBottom: v()], positioning: CGPoint(x: -10, y: -10))
    imageView.addCornerViews([.leftTop: removeButton], positioning: .zero, panEnabled: false)
    
    imageView.delegate = self
    
    view.addSubview(imageView)
  }
  
  @objc fileprivate func remove() {
    imageView.removeFromSuperview()
  }
  
  @IBAction func touchDownBackground() {
    imageView.hideCornerViews()
  }

  func pinchableImageViewTouchesBegan(_ pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {
    pinchableImageView.showCornerViews()
  }

  func pinchableImageViewTouchesMoved(_ pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {

  }

  func pinchableImageViewTouchesEnded(_ pinchableImageView: PinchableImageView, touches: Set<UITouch>, withEvent event: UIEvent?) {

  }
}

