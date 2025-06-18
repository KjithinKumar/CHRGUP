//
//  ColorManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 27/02/25.
//

import UIKit

struct ColorManager {
    static let primaryColor = UIColor(hex: "#ADDD8C") // Primary/500
    
    static let primaryTextColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#ADDD8C") : UIColor(hex: "#5DAD41")
    }
    static let backgroundColor = UIColor.systemBackground
    
    static let textColor = UIColor.label
    
    static let subtitleTextColor = UIColor.secondaryLabel

    static let buttonTintColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .white : .black
    } //Neutral/100
    
    static let buttonTextColor = UIColor.black
    
    static let secondaryBackgroundColor = UIColor.secondarySystemBackground
    
    static let placeholderColor = UIColor(hex: "#767676") //Neutral/300
    
    static let thirdBackgroundColor =  UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .tertiaryLabel
    }//Neutral/400
    
    static let acbulletColor = UIColor(hex: "#30D5C8")
    static let dcbulletColor = UIColor(hex: "#F2771A")
    
    static let inUseColor = UIColor(hex: "#95C1DF")
    
    static let pendingColor = UIColor(hex: "#F74141")
    
    static let cancelledColor = UIColor(hex: "#FF795E")  // soft coral (original)

    static let completedColor = UIColor(hex: "#BFFF86")  // lime green (original)

    static let reservedColor = UIColor(hex: "#ACEAFF")  // sky blue (original)
}



//<color name="primary200">#63BF95</color><color name="primary300">#63BF95</color><color name="primary500">#63BF95</color><color name="secondary500">#2C60B4</color>
//UIColor(hex: "#1A1A1A") background
//UIColor(hex: "#272727") secondarybackground
//UIColor(hex: "#E8E8E8") textColor
//UIColor(hex: "#4C4C4C") thirdbackgroundColor
//UIColor(hex: "#BABABA") subtitleTextColor
//UIColor(hex: "#BABABA") buttonColor
//UIColor(hex: "#E8E8E8") buttonColorWhite
//UIColor(hex: "#ADDD8C") PrimaryColor
//UIColor(hex: "#ADDD8C") primaryTextColorWhiteMode
