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
                actions.forEach { alertController.addAction($0) }
                self.present(alertController, animated: true)
            }
        }
    }
    func dismissAlert(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let presentedAlert = self.presentedViewController as? UIAlertController {
                presentedAlert.dismiss(animated: true, completion: nil)
            }else{
                completion?()
            }
        }
    }
}
class AlertActions {
    static func loginAgainAction() -> UIAlertAction {
        return UIAlertAction(title: "Login Again", style: .default) { _ in
            let welcomeVc = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
             let navigationController = UINavigationController(rootViewController: welcomeVc)
             navigationController.modalPresentationStyle = .fullScreen
             navigationController.navigationBar.tintColor = ColorManager.buttonColorwhite
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = navigationController
            UserDefaultManager.shared.setLoginStatus(false)
        }
    }
    static func logoutAction() -> UIAlertAction {
        return UIAlertAction(title: "Logout", style: .destructive) { _ in
            let welcomeVc = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
             let navigationController = UINavigationController(rootViewController: welcomeVc)
             navigationController.modalPresentationStyle = .fullScreen
             navigationController.navigationBar.tintColor = ColorManager.buttonColorwhite
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = navigationController
            UserDefaultManager.shared.setLoginStatus(false)
        }
    }
}
