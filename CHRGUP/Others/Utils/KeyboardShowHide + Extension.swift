//
//  KeyboardShowHide + Extension.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 04/03/25.
//

import Foundation
import UIKit

extension UIViewController {
    
    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        let offset = keyboardHeight - safeAreaBottom - 20
        
        UIView.animate(withDuration: duration) {[weak self] in
            guard let self else { return }
            self.moveViewForKeyboard(yOffset: -offset)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        UIView.animate(withDuration: duration) { [weak self] in
            guard let self else { return }
            self.moveViewForKeyboard(yOffset: 0)
        }
    }
    
    @objc func moveViewForKeyboard(yOffset: CGFloat) {
        // Default implementation does nothing, meant to be overridden
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
