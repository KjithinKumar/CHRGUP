//
//  DeepLinkManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 17/04/25.
//

import RNCryptor
import UIKit

func decryptChargerId(_ encryptedBase64: String) -> String? {
    guard let encryptedData = Data(base64Encoded: encryptedBase64.removingPercentEncoding ?? "") else {
        return nil
    }

    let password = "Ankit@Sinha" // Use the same one used for encryption

    do {
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: password)
        return String(data: decryptedData, encoding: .utf8)
    } catch {
        print("Decryption failed: \(error)")
        return nil
    }
}


class DeepLinkManager {
    static let shared = DeepLinkManager()
    
    func handle(url: URL) {
        print("Incoming URL: \(url.absoluteString)")
        
        guard url.scheme == "chrgup",
              url.host == "scan",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let payload = components.queryItems?.first(where: { $0.name == "payload" })?.value,
              let decrypted = decryptChargerId(payload) else {
            print("Invalid or missing payload")
            return
        }
        
        print("Decrypted payload (chargerId): \(decrypted)")
        routeToStartCharging(with: decrypted)
    }

    func routeToStartCharging(with chargerId: String) {
        // Get root navigation controller
        guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }

        // Find current top view controller
        let topVC = getTopViewController(from: rootVC)

        // Create the StartCharging screen
        let vc = ScanQrViewController()
        //vc.chargerId = chargerId  // Set your model or property
        debugPrint(chargerId)

        // Push or present it
        if let nav = topVC?.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            topVC?.present(vc, animated: true)
        }
    }

    private func getTopViewController(from root: UIViewController?) -> UIViewController? {
        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
