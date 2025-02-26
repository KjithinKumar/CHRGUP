//
//  UIWindow+Extension.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/02/25.
//

import Foundation
import UIKit

extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        guard let scene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return nil }
        
        return scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
    }
}
