//
//  ColorManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 27/02/25.
//

import UIKit

struct ColorManager {
    static let primaryColor = UIColor(hex: "#ADDD8C") // Primary/500
    
    static let primaryTextColor = UIColor { _ in
        switch AppSettings.appearanceMode {
        case .light:
            return UIColor(hex: "#5DAD41")
        case .dark:
            return UIColor(hex: "#ADDD8C")
        case .system:
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                    ? UIColor(hex: "#ADDD8C")
                    : UIColor(hex: "#5DAD41")
            }
        }
    }
    static let backgroundColor = UIColor.systemBackground
    
    static let textColor = UIColor.label
    
    static let subtitleTextColor = UIColor.secondaryLabel

    static let buttonTintColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
    
    static let buttonTextColor = UIColor.black
    
    static let secondaryBackgroundColor = UIColor.secondarySystemBackground
    
    static let placeholderColor = UIColor(hex: "#767676") //Neutral/300
    
    static let thirdBackgroundColor = UIColor { _ in
        switch AppSettings.appearanceMode {
        case .light:
            return UIColor.systemGray5
        case .dark:
            return UIColor.tertiarySystemBackground
        case .system:
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                ? UIColor.tertiarySystemBackground : UIColor.systemGray5
            }
        }
    }
    
    static let acbulletColor = UIColor(hex: "#30D5C8")
    static let dcbulletColor = UIColor(hex: "#F2771A")
    
    static let inUseColor = UIColor(hex: "#95C1DF")
    
    static let pendingColor = UIColor(hex: "#F74141")
    
    static let cancelledColor = UIColor(hex: "#FF795E")  // soft coral (original)

    static let completedColor = UIColor(hex: "#BFFF86")  // lime green (original)

    static let reservedColor = UIColor(hex: "#ACEAFF")  // sky blue (original)
    
    static let redColor = UIColor(hex: "#F74141")
}

