//
//  FontManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 27/02/25.
//

import Foundation
import UIKit

struct FontManager{
    static func regular(size: CGFloat = 17) -> UIFont {
        return UIFont(name: "roboto", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func bold(size: CGFloat = 34) -> UIFont {
        return UIFont(name: "roboto_bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func light(size: CGFloat = 14) -> UIFont {
        return UIFont(name: "roboto_light", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
}
