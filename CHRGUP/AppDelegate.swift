//
//  AppDelegate.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseMessaging
import UserNotifications
import ActivityKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let _ = InternetManager.shared
        return true
    }
    // MARK: SignIn with Google
    func application(_ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    func reconnectToLiveActivityIfNeeded() {
        Task {
            if #available(iOS 16.2, *) {
                let activities = Activity<ChargingLiveActivityAttributes>.activities
                if let existing = activities.first {
                    ChargingLiveActivityManager.reconnect(to: existing)
                }
            }
        }
    }
}


