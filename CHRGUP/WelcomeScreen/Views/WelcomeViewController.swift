//
//  WelcomeViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 27/02/25.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var vStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        configureUi()
        UserDefaultManager.shared.setOnboardingCompleted(true)
        UserDefaultManager.shared.resetFavouriteLocations()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .clear
    }

    @IBAction func ContinueButtonPressed(_ sender: Any) {
        navigateToSignIn(with: .SignIn)
    }
    func configureUi() {
        overlayView.layer.cornerRadius = 20
        overlayView.backgroundColor = ColorManager.backgroundColor
        UIView.animate(withDuration: 0.25) {
            self.overlayView.center.y -= self.overlayView.frame.height
        }
        
        continueButton.layer.cornerRadius = 20
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        continueButton.backgroundColor = ColorManager.buttonTintColor
        continueButton.setTitle(AppStrings.Welcome.continueButtonTitle, for: .normal)
        continueButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        continueButton.titleLabel?.font = FontManager.bold(size: 18)
        
        continueButton.imageView?.tintColor = ColorManager.backgroundColor
        
        welcomeLabel.text = AppStrings.Welcome.welcomeTitle
        welcomeLabel.textColor = ColorManager.textColor
        welcomeLabel.font = FontManager.bold(size: 40)

        
        subtitleLabel.text = AppStrings.Welcome.welcomeSubtitle
        subtitleLabel.textColor = ColorManager.subtitleTextColor
        subtitleLabel.font = FontManager.regular()
        
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.textColor = ColorManager.subtitleTextColor
        signUpLabel.font = FontManager.regular()
        let text = AppStrings.Welcome.signupTitle
        let attributedText = NSMutableAttributedString(string: text)
        let boldFont = FontManager.bold(size: 14)
        attributedText.addAttribute(.font, value: boldFont, range: (text as NSString).range(of: "Sign Up"))
        attributedText.addAttribute(.foregroundColor, value: ColorManager.primaryTextColor, range: (text as NSString).range(of: "Sign Up"))

        signUpLabel.attributedText = attributedText
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUplabelTapped))
        signUpLabel.addGestureRecognizer(tapGesture)
        navigationItem.backButtonTitle = ""

    }
    @objc func SignUplabelTapped() {
        navigateToSignIn(with: .SignUp)
    }
    
    func navigateToSignIn(with : AuthMode){
        navigationController?.navigationBar.tintColor = ColorManager.buttonTintColor
        switch with {
        case .SignIn:
            let signInVc = MobileNumberViewController()
            signInVc.authMode = .SignIn
            navigationController?.navigationBar.isHidden = false
            navigationController?.pushViewController(signInVc, animated: true)
        case .SignUp:
            let signUpVc = MobileNumberViewController()
            navigationController?.navigationBar.isHidden = false
            signUpVc.authMode = .SignUp
            navigationController?.pushViewController(signUpVc, animated: true)
        }
    }
}
