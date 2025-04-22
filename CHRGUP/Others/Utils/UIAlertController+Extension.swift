//
//  UIAlertController+Extension.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(
        title: String?,
        message: String?,
        style: UIAlertController.Style = .alert,
        actions: [UIAlertAction] = [UIAlertAction(title: AppStrings.Alert.ok, style: .default, handler: nil)]
    ) {
        
        DispatchQueue.main.async {
            self.dismissAlert { [weak self] in
                guard let self = self else { return }
                let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
                actions.forEach {
                    if $0.style == .default {
                        $0.setValue(ColorManager.primaryColor, forKey: "titleTextColor")
                    }
                    
                    alertController.addAction($0)
                }
                self.present(alertController, animated: true)
            }
        }
    }
    func dismissAlert(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let presentedAlert = self.presentedViewController as? UIAlertController {
                presentedAlert.dismiss(animated: true)
            }else{
                completion?()
            }
        }
    }
}
class AlertActions {
    static func loginAgainAction() -> UIAlertAction {
        return UIAlertAction(title: "Login Again", style: .default) { _ in
            UserDefaultManager.shared.setLoginStatus(false)
            GlobalAlertGuard.didShow401Alert = false
            let welcomeVc = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
             let navigationController = UINavigationController(rootViewController: welcomeVc)
             navigationController.modalPresentationStyle = .fullScreen
             navigationController.navigationBar.tintColor = ColorManager.buttonColorwhite
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = navigationController
        }
    }
    static func logoutAction() -> UIAlertAction {
        return UIAlertAction(title: "Logout", style: .destructive) { _ in
            UserDefaultManager.shared.setLoginStatus(false)
            let welcomeVc = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
            if let rootNav = UIApplication.shared.connectedScenes
                        .compactMap({ ($0.delegate as? SceneDelegate)?.window?.rootViewController as? UINavigationController }) // safely cast
                .first {
                rootNav.navigationBar.isTranslucent = true
                rootNav.view.backgroundColor = .clear
                rootNav.navigationBar.backgroundColor = .clear
                rootNav.setViewControllers([welcomeVc], animated: true)
                
            }
            
        }
    }
}
class GlobalAlertGuard {
    static var didShow401Alert = false
}
