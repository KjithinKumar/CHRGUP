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
        
        if let _ = self.presentedViewController as? UIAlertController {
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { alertController.addAction($0) }
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func dismissAlert() {
        DispatchQueue.main.async {
            if let presentedAlert = self.presentedViewController as? UIAlertController {
                presentedAlert.dismiss(animated: true, completion: nil)
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
        }
    }
}
