//
//  ToastManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 18/03/25.
//


import UIKit

class ToastManager {
    static let shared = ToastManager()
    
    private var toastLabel: UILabel?

    private init() {}

    func showToast(message: String) {
        guard let window = UIApplication.shared.currentUIWindow() else { return }
        
        // Remove previous toast if exists
        toastLabel?.removeFromSuperview()
        
        let toast = UILabel()
        toast.text = message
        toast.textAlignment = .center
        toast.backgroundColor = ColorManager.secondaryBackgroundColor.withAlphaComponent(0.8)
        toast.textColor = ColorManager.subtitleTextColor
        toast.layer.cornerRadius = 20
        toast.clipsToBounds = true
        toast.alpha = 0.0
        
        // Set Frame
        let toastWidth = window.frame.width - 100
        let toastHeight: CGFloat = 40
        let yPosition = window.frame.height - toastHeight - 50
        toast.frame = CGRect(x: 50, y: yPosition, width: toastWidth, height: toastHeight)
        
        window.addSubview(toast)
        toastLabel = toast
        
        // Fade-in animation
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1.0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.3, animations: {
                    toast.alpha = 0.0
                }) { _ in
                    toast.removeFromSuperview()
                }
            }
        }
    }
}
