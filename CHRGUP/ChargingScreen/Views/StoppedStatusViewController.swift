//
//  StoppedStatusViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 29/09/25.
//

import UIKit
import Lottie

class StoppedStatusViewController: UIViewController {
    @IBOutlet weak var redirectLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var animView: UIView!
    @IBOutlet weak var paymentOfLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var successfulLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var viewReceiptButton: UIButton!
    
    var viewModel : ReceiptViewModelInterface?
    var countdownTimer: Timer?
    var remainingTime = 20
    var autoStoppedresponse : ChargingStatusResponseModel?
    var forceStopResponse : StopChargingResponseModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        configureData()
        UserDefaultManager.shared.saveSessionStatus("stopped")
    }
    func setUpUI(){
        view.backgroundColor = ColorManager.secondaryBackgroundColor
        
        paymentOfLabel.text = AppStrings.StopCharger.paymentOf
        paymentOfLabel.textColor = ColorManager.textColor
        paymentOfLabel.font = FontManager.regular()
        
        amountLabel.text = " ₹ 0.0"
        amountLabel.font = FontManager.bold()
        amountLabel.textColor = ColorManager.primaryTextColor
        
        successfulLabel.text = AppStrings.StopCharger.paid
        successfulLabel.textColor = ColorManager.textColor
        successfulLabel.font = FontManager.regular()
        
        messageView.backgroundColor = ColorManager.thirdBackgroundColor
        messageView.layer.cornerRadius = 20
        
        messageLabel.text = "Your charging session has been stopped because you wallet balance is low"
        messageLabel.font = FontManager.light()
        
        let skipAttributedString = NSAttributedString(
            string: AppStrings.StopCharger.skip,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: ColorManager.subtitleTextColor,
                .font: FontManager.light()
            ]
        )
        skipButton.setAttributedTitle(skipAttributedString, for: .normal)
        
        let viewReceiptAttributedString = NSAttributedString(
            string: AppStrings.StopCharger.viewReceipt,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: ColorManager.subtitleTextColor,
                .font: FontManager.light()
            ]
        )
        viewReceiptButton.setAttributedTitle(viewReceiptAttributedString, for: .normal)
        
        redirectLabel.textColor = ColorManager.subtitleTextColor
        redirectLabel.font = FontManager.light()
        
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                      target: self,
                                                      selector: #selector(updateCountdown),
                                                      userInfo: nil,
                                                      repeats: true)
        let animationView = LottieAnimationView(name: "tick_anim.json")
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.frame = animationView.bounds// Set size
        
        animationView.contentMode = .scaleAspectFit // Adjust scaling
        animationView.loopMode = .loop // Loop animation
        animationView.animationSpeed = 1.0 // Set speed
        
        animView.addSubview(animationView)
        animationView.play()
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: animView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: animView.centerYAnchor)
        ])
        animView.backgroundColor = ColorManager.secondaryBackgroundColor
        
        
    }
    @objc private func updateCountdown() {
        remainingTime -= 1
        updateLabel()
        if remainingTime <= 0 {
            countdownTimer?.invalidate()
            redirectToNextScreen()
        }
    }
    private func updateLabel() {
        redirectLabel.text = "Redirecting in \(remainingTime) seconds..."
    }
    private func redirectToNextScreen() {
        checkIfReviewed()
    }
    func configureData(){
        if let autoresponse = autoStoppedresponse{
            if let amount = autoresponse.amount{
                amountLabel.text = " ₹\(amount)"
            }
            if let message = autoresponse.message{
                messageLabel.text = message
            }
        }
        if let forceResponse = forceStopResponse{
            if let amount = forceResponse.amount{
                amountLabel.text = " ₹\(amount)"
            }
            if let message = forceResponse.message{
                messageLabel.text = message
            }
        }
    }
    
    @IBAction func viewReceiptButtonPressed(_ sender: Any) {
        let receiptVc = ReceiptViewController()
        receiptVc.viewModel = ReceiptViewModel(networkManager: NetworkManager.shared)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.setViewControllers([receiptVc], animated: true)
    }
    @IBAction func skipButtonPressed(_ sender: Any) {
        disableButtonWithActivityIndicator(skipButton)
        checkIfReviewed()
    }
    func checkIfReviewed(){
        self.viewModel?.checkReviewforLocation { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case.success(let response):
                    if response.success{
                        if response.hasReviewed ?? true{
                            UserDefaultManager.shared.deleteScannedLocationId()
                            self.dismiss(animated: true)
                        }else{
                            let reviewVc = ReviewViewController()
                            reviewVc.viewModel = ReviewViewModel(networkManager: NetworkManager.shared)
                            self.navigationController?.setViewControllers([reviewVc], animated: true)
                        }
                    }else{
                        self.showAlert(title: "Error", message: response.message)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
            iOSWatchSessionManger.shared.sendStatusToWatch()
        }
    }
}
