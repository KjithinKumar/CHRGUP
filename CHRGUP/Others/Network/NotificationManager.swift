//
//  NotificationManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 05/06/25.
//

import Foundation
import UserNotifications
import FirebaseMessaging
import UIKit

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    static let shared = NotificationManager()

    func configure() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    func sendChargingStartedNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Charging Started"
            content.body = "Your vehicle charging has started successfully."
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    debugPrint("Error scheduling local notification: \(error.localizedDescription)")
                } else {
                    debugPrint("Charging Started Notification scheduled.")
                }
            }
        }

        func sendChargingEndedNotification(message: String) {
            let content = UNMutableNotificationContent()
            content.title = "Charging Ended"
            content.body = message
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    debugPrint("Error scheduling local notification: \(error.localizedDescription)")
                } else {
                    debugPrint("Charging Ended Notification scheduled.")
                }
            }
        }
    
}
