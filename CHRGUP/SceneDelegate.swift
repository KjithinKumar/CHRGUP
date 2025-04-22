//
//  SceneDelegate.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let splashVC = SplashScreenViewController()// Your splash screen view controller
        splashVC.viewModel = SplashScreenViewModel(networkManager: NetworkManager(), delegate : splashVC)
        let navController = UINavigationController(rootViewController: splashVC)
        navController.navigationBar.tintColor = ColorManager.buttonColorwhite
        window.rootViewController = navController
        window.overrideUserInterfaceStyle = .dark
        self.window = window
        window.makeKeyAndVisible()
        if let url = connectionOptions.urlContexts.first?.url {
            if let payLoad = DeepLinkManager.shared.handle(url: url) {
                DeepLinkManager.shared.pendingPayload = payLoad
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let topMapVc = navController.viewControllers.first as? MapScreenViewController {
                        topMapVc.handleDeepLinkIfNeeded()
                    }
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if let payLoad = DeepLinkManager.shared.handle(url: url){
                DeepLinkManager.shared.pendingPayload = payLoad
                if let rootNav = UIApplication.shared.connectedScenes
                            .compactMap({ ($0.delegate as? SceneDelegate)?.window?.rootViewController as? UINavigationController }) // safely cast
                    .first {
                    let topMapVc = rootNav.viewControllers.first
                    rootNav.popToRootViewController(animated: true)
                    if let topMapVc = topMapVc as? MapScreenViewController {
                        topMapVc.handleDeepLinkIfNeeded()
                    }
                }
            }
        }
    }
}

