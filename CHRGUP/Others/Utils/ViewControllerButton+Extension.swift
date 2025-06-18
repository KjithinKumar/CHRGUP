//
//  ViewControllerButton+Extension.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 08/05/25.
//

import Foundation
import UIKit
extension UIViewController {
    func disableButtonWithActivityIndicator(_ button: UIButton,
                                            indicatorColor: UIColor = ColorManager.backgroundColor,
                                            titleColor: UIColor = ColorManager.primaryColor) {
        button.isUserInteractionEnabled = false
        button.setTitleColor(titleColor, for: .normal)

        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = indicatorColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tag = 9999 // Tag to identify and remove later

        button.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        indicator.startAnimating()
    }

    func enableButtonAndRemoveIndicator(_ button: UIButton,
                                        titleColor: UIColor = ColorManager.buttonTextColor) {
        button.isUserInteractionEnabled = true
        button.setTitleColor(titleColor, for: .normal)

        // Find and remove the activity indicator by tag
        if let indicator = button.viewWithTag(9999) as? UIActivityIndicatorView {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
}
