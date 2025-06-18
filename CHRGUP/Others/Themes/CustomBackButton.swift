//
//  CustomBackButton.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 05/03/25.
//

import Foundation
import UIKit

func createCustomBackButton(target: Any?, action: Selector?) -> UIButton {
    let button = UIButton(type: .system)
    let backImage = UIImage(systemName: "chevron.left")?
        .applyingSymbolConfiguration(UIImage.SymbolConfiguration(weight: .bold)) // Make it bold
    
    button.setImage(backImage, for: .normal)
    button.tintColor = ColorManager.buttonTintColor
    button.contentHorizontalAlignment = .left
    button.frame = CGRect(x: 0, y: 0, width: 44, height: 44) // Match system size
    
    if let action = action {
        button.addTarget(target, action: action, for: .touchUpInside)
    }
    
    return button
}
