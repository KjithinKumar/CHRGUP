//
//  InternetManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import Foundation
import UIKit
import Network


class InternetManager{
    static let shared = InternetManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    private var isShowingAlert = false
    
    private var debounceWorkItem: DispatchWorkItem? // For debounce timer
    
    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                 self.debouncedVerifyInternetConnection()
            }
        }
        monitor.start(queue: queue)
    }
    
    var topVC : UIViewController?
    private func showNoInternetAlert() {
        topVC = UIApplication.shared.getCurrentViewController()
        topVC?.showAlert(title: AppStrings.Alert.noInternetTitle,
                        message: AppStrings.Alert.noInternetMessage,
                        actions: [UIAlertAction(title: AppStrings.Alert.settings, style: .default) { _ in
            if let url = URL(string: URLs.mobileDataSettingsUrl) {
                UIApplication.shared.open(url)
            }
        }]
        )
        isShowingAlert = true
    }
    private func dismissNoInternetAlert() {
        topVC?.dismissAlert()
        isShowingAlert = false
    }
    private func debouncedVerifyInternetConnection() {
        debounceWorkItem?.cancel() // Cancel any pending task
        
        debounceWorkItem = DispatchWorkItem { [weak self] in
            self?.verifyInternetConnection()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: debounceWorkItem!) // 1.5s delay
    }
    private func verifyInternetConnection() {
        guard let url = URL(string: URLs.appleTestUrl) else { return }
        let request = URLRequest(url: url)
                let task = URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if self.isShowingAlert {
                        self.dismissNoInternetAlert()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            NotificationCenter.default.post(name: .internetRestored, object: nil)
                        })
                    }
                     // Internet is working
                } else {
                    self.showNoInternetAlert() // No internet access
                }
            }
        }
        task.resume()
    }
}


extension UIApplication {
    func getCurrentViewController() -> UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = keyWindow.rootViewController else {
            return nil
        }
        return getVisibleViewController(from: rootViewController)
    }

    private func getVisibleViewController(from vc: UIViewController) -> UIViewController? {
        if let presentedVC = vc.presentedViewController {
            return getVisibleViewController(from: presentedVC)
        } else if let navigationController = vc as? UINavigationController {
            return getVisibleViewController(from: navigationController.visibleViewController ?? navigationController)
        } else if let tabBarController = vc as? UITabBarController {
            return getVisibleViewController(from: tabBarController.selectedViewController ?? tabBarController)
        }
        return vc
    }
}
