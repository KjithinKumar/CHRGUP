//
//  AppAppearance.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 13/06/25.
//

import Foundation
import UIKit

enum AppAppearance: String {
    case light, dark, system
}

class AppSettings {
    private static let appearanceKey = "AppAppearance"

    static var appearanceMode: AppAppearance {
        get {
            return UserDefaultManager.appAppearance
        }
        set {
            UserDefaultManager.appAppearance = newValue
        }
    }

    static func applyAppearance() {
        guard let window = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootWindow = window.windows.first else {
            return
        }

        switch UserDefaultManager.appAppearance {
        case .light:
            rootWindow.overrideUserInterfaceStyle = .light
        case .dark:
            rootWindow.overrideUserInterfaceStyle = .dark
        case .system:
            rootWindow.overrideUserInterfaceStyle = .unspecified
        }
    }
}
extension AppAppearance {
//    var isDarkMode: Bool {
//        switch self {
//        case .dark: return true
//        case .light: return false
//        case .system:
//            return UITraitCollection.current.userInterfaceStyle == .dark
//        }
//    }
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
}
//extension AppSettings {
//    static func resolvedInterfaceStyle(_ traitCollection: UITraitCollection) -> UIUserInterfaceStyle {
//        switch AppSettings.appearanceMode {
//        case .system:
//            return traitCollection.userInterfaceStyle
//        case .dark:
//            return .dark
//        case .light:
//            return .light
//        }
//    }
//}
