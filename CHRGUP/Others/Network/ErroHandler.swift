//
//  ErroHandler.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 05/04/25.
//
import UIKit
import Foundation
enum AppErrorHandler {
    static func handle(_ error: Error, in viewController: UIViewController) {
        if let error = error as? NetworkManagerError {
            switch error {
            case .serverError(let message, let code):
                DispatchQueue.main.async {
                    if code == 401 {
                        guard GlobalAlertGuard.didShow401Alert == false else { return }
                        GlobalAlertGuard.didShow401Alert = true
                        let topVC = viewController.topMostViewController
                            topVC.dismissAlert {
                                let actions = [AlertActions.loginAgainAction()]
                                topVC.showAlert(title: "Unauthorized", message: message, actions: actions)
                            }
                    } else {
                        viewController.showAlert(title: "Error", message: message)
                    }
                }
            case .decodingFailed:
                viewController.showAlert(title: "Error", message: "Internal Server Error")
            case .invalidRequest:
                viewController.showAlert(title: "Error", message: "Server Error")
            default:
                break
            }
        } else {
            debugPrint("Unhandled Error:", error)
        }
    }
}
extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController
        } else if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController ?? nav
        } else if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        return self
    }
}
