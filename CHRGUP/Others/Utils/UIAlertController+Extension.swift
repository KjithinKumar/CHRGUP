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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismissAlert { [weak self] in
                guard let self = self else { return }
                let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
                actions.forEach {
                    if $0.style == .default {
                        $0.setValue(ColorManager.primaryTextColor, forKey: "titleTextColor")
                    }
                    
                    alertController.addAction($0)
                }
                if UIDevice.current.userInterfaceIdiom == .pad && style == .actionSheet {
                    if let popover = alertController.popoverPresentationController {
                        popover.sourceView = self.view
                        popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                }
                self.present(alertController, animated: true)
            }
        }
    }
    func dismissAlert(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
            UserDefaultManager.shared.logoutUserProfile()
            Task{
                await ChargingLiveActivityManager.endActivity()
            }
            GlobalAlertGuard.didShow401Alert = false
            let welcomeVc = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
            let navigationController = UINavigationController(rootViewController: welcomeVc)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.tintColor = ColorManager.buttonTintColor
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = navigationController
        }
    }
    static func logoutAction() -> UIAlertAction {
        return UIAlertAction(title: "Logout", style: .destructive) { _ in
            UserDefaultManager.shared.logoutUserProfile()
            iOSWatchSessionManger.shared.sendStatusToWatch()
            let welcomeVc = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
            let navigationController = UINavigationController(rootViewController: welcomeVc)
            Task{
                await ChargingLiveActivityManager.endActivity()
            }
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.tintColor = ColorManager.buttonTintColor
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = navigationController
        }
    }
}
class GlobalAlertGuard {
    static var didShow401Alert = false
}
