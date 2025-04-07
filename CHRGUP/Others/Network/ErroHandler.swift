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
                        let actions = [AlertActions.loginAgainAction()]
                        viewController.showAlert(title: "Unauthorized", message: message, actions: actions)
                    } else {
                        viewController.showAlert(title: "Error", message: message)
                    }
                }
            default:
                break
            }
        } else {
            debugPrint("Unhandled Error:", error)
        }
    }
}
