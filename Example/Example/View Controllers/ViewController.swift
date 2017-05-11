//
//  ViewController.swift
//  PinchToZoomImageView
//
//  Created by Josh Sklar on 5/9/17.
//  Copyright © 2017 StockX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var createdInCodeLabel: UILabel!
    let pinchToZoomImageView = PinchToZoomImageView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinchToZoomImageView.image = #imageLiteral(resourceName: "Sunset")
        view.addSubview(pinchToZoomImageView)
        pinchToZoomImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String : Any] = ["imageView": pinchToZoomImageView, "label": createdInCodeLabel]
        let metrics = ["size": 200]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[imageView(size)]",
                                                           options: [],
                                                           metrics: metrics,
                                                           views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView(size)]",
                                                           options: [],
                                                           metrics: metrics,
                                                           views: views))
        view.addConstraint(NSLayoutConstraint(item: pinchToZoomImageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
    }


}
