//
//  SignUpViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 22/04/25.
//

import UIKit

protocol SignUpViewControllerDelegate: AnyObject {
    func didSignUp(userProfile : UserProfile)
    func didCancelSignUp()
    func didfailedToSignUp(error: any Error)
}

class SignUpViewController: UIViewController {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: SignUpViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = ColorManager.backgroundColor.withAlphaComponent(0.5)
        }
        
    }
    @IBAction func appleSignUpPressed(_ sender: Any) {

    }
    @IBAction func googleSignUpPressed(_ sender: Any) {
        GoogleSignInHelper.shared.signIn(with: self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userProfile):
                self.dismiss(animated: true) {
                    self.delegate?.didSignUp(userProfile: userProfile)
                }
            case .failure(let error):
                ToastManager.shared.showToast(message: error.localizedDescription)
                self.delegate?.didfailedToSignUp(error: error)
            }
        }
    }
    
    func setUpUI(){
        view.backgroundColor = .clear
        
        bottomView.backgroundColor = ColorManager.secondaryBackgroundColor
        bottomView.layer.cornerRadius = 20
        bottomView.clipsToBounds = true
        
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.bold(size: 24)
        titleLabel.text = AppStrings.signUp.title
        
        googleButton.layer.cornerRadius = 20
        googleButton.backgroundColor = ColorManager.primaryColor
        googleButton.setTitle(" Sign Up with Google", for: .normal)
        googleButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        googleButton.setImage(UIImage(named: "GoogleIcon"), for: .normal)
        googleButton.imageView?.contentMode = .redraw
        googleButton.imageView?.tintColor = ColorManager.backgroundColor
        googleButton.titleLabel?.font = FontManager.bold(size: 18)
        
        appleButton.layer.cornerRadius = 20
        appleButton.backgroundColor = ColorManager.primaryColor
        appleButton.setTitle("  Sign Up with Apple", for: .normal)
        appleButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        appleButton.setImage(UIImage(systemName: "apple.logo"), for: .normal)
        appleButton.imageView?.tintColor = ColorManager.backgroundColor
        appleButton.titleLabel?.font = FontManager.bold(size: 18)
    }
}
