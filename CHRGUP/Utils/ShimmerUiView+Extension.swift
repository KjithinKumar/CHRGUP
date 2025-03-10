//
//  ShimmerUiView+Extension.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 06/03/25.
//

import Foundation
import UIKit
import ObjectiveC

private var shimmerLayerKey: UInt8 = 0

extension UIView {
    
    func startShimmering() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(white: 1.0, alpha: 0.65).cgColor,
            UIColor(white: 1.0, alpha: 1.0).cgColor,
            UIColor(white: 1.0, alpha: 0.65).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        
        self.layer.masksToBounds = true
        self.layer.mask = gradientLayer
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.2
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "shimmer")
        
        objc_setAssociatedObject(self, &shimmerLayerKey, gradientLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func stopShimmering() {
        if let shimmerLayer = objc_getAssociatedObject(self, &shimmerLayerKey) as? CAGradientLayer {
            shimmerLayer.removeFromSuperlayer()
            objc_setAssociatedObject(self, &shimmerLayerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
