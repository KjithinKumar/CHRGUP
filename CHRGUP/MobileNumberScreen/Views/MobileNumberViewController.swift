//
//  MobileNumberViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 28/02/25.
//

import UIKit

enum AuthMode {
    case SignIn
    case SignUp
}

class MobileNumberViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeSubtitleLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var termsLabel: UILabel!
    
    var authMode: AuthMode = .SignIn
    private var isChecked : Bool = false
    private var isValidMobileNumber: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureUi()
        configureNavBar()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func configureAuth() {
        switch authMode {
        case .SignIn:
            welcomeLabel.text = AppStrings.Auth.welcomBackTitle
            welcomeSubtitleLabel.text = AppStrings.Auth.welcomeSubtitle
            signInButton.setTitle(AppStrings.Auth.signInButtonTitle, for: .normal)
        case .SignUp:
            welcomeLabel.text = AppStrings.Auth.welcomeTitle
            welcomeSubtitleLabel.text = AppStrings.Auth.welcomeSubtitle
            signInButton.setTitle(AppStrings.Auth.signUpButtonTitle, for: .normal)
        }
    }
    func configureUi(){
        view.backgroundColor = ColorManager.backgroundColor
        
        welcomeLabel.font = FontManager.bold()
        welcomeLabel.textColor = ColorManager.textColor
        
        welcomeSubtitleLabel.textColor = ColorManager.textColor
        welcomeSubtitleLabel.font = FontManager.regular()
        
        mobileNumberTextField.delegate = self
        mobileNumberTextField.backgroundColor = ColorManager.secondaryBackgroundColor
        mobileNumberTextField.layer.cornerRadius = 20
        mobileNumberTextField.textColor = ColorManager.primaryColor
        mobileNumberTextField.tintColor = ColorManager.primaryColor
        mobileNumberTextField.attributedPlaceholder = NSAttributedString(string: AppStrings.Auth.placeHolder,attributes: [NSAttributedString.Key.foregroundColor: ColorManager.placeholderColor,NSAttributedString.Key.font: FontManager.light()])
        //mobileNumberTextField.textColor = ColorManager.textColor
        mobileNumberTextField.font = FontManager.regular()
        mobileNumberTextField.borderStyle = .roundedRect
        mobileNumberTextField.keyboardType = .numberPad
        mobileNumberTextField.tag = 0
        mobileNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        mobileNumberLabel.textColor = ColorManager.textColor
                mobileNumberLabel.font = FontManager.regular()
        
        
        signInButton.backgroundColor = ColorManager.primaryColor
        signInButton.tintColor = ColorManager.backgroundColor
        signInButton.layer.cornerRadius = 20
        signInButton.isEnabled = false
        
        termsLabel.isUserInteractionEnabled = true
        termsLabel.textColor = ColorManager.textColor
        termsLabel.font = FontManager.light()
        let text = AppStrings.Auth.terms
        let termsRange = (text as NSString).range(of: "Terms & Conditions")
        let privacyRange = (text as NSString).range(of: "Privacy\nPolicy")
        let cancelationRange = (text as NSString).range(of: "Cancelation & Refund Policy")
        let AttributedString = NSMutableAttributedString(string: AppStrings.Auth.terms)
        AttributedString.addAttribute(.foregroundColor, value: ColorManager.primaryColor, range: termsRange)
        AttributedString.addAttribute(.foregroundColor, value: ColorManager.primaryColor, range: privacyRange)
        AttributedString.addAttribute(.foregroundColor, value: ColorManager.primaryColor, range: cancelationRange)
        termsLabel.attributedText = AttributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTermsTap))
        termsLabel.addGestureRecognizer(tapGesture)
        
        
        
        checkButton.backgroundColor = ColorManager.backgroundColor
        checkButton.setImage(nil, for: .normal)
        checkButton.tintColor = ColorManager.backgroundColor
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    func configureNavBar(){
        navigationController?.isNavigationBarHidden = false
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Vector"), for: .normal)
        button.backgroundColor = .clear
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    @objc func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func checkButtonPressed(_ sender: Any) {
        isChecked.toggle()
        if isChecked {
            checkButton.tintColor = ColorManager.primaryColor
            signInButton.isEnabled = true
        }else{
            checkButton.tintColor = ColorManager.backgroundColor
            signInButton.isEnabled = false
        }
        updateSignInButtonState()
    }
    func updateSignInButtonState(){
        signInButton.isEnabled = isChecked && isValidMobileNumber
    }
}

extension MobileNumberViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if mobileNumberTextField.tag == 0{
            textField.text = AppStrings.MobileExtension.Ind
            textField.tag = 1
        }
        
    }
    @objc func textFieldDidChange(){
        //Do any checks for entered text
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }

        // Prevent deletion of "+91 "
        if range.location < 4 {
            return false
        }
        
        let newLength = text.count + string.count - range.length
        if newLength > 14 {
            return false
        }
        isValidMobileNumber = (newLength == 14)
        updateSignInButtonState()

        // Limit total length to 14 (including "+91 " prefix)
        return true
    }
}

extension MobileNumberViewController{
    @objc func handleTermsTap(_ gesture : UITapGestureRecognizer){
        let text = AppStrings.Auth.terms
        let termsRange = (text as NSString).range(of: "Terms & Conditions")
        let privacyRange = (text as NSString).range(of: "Privacy\nPolicy")
        let cancelationRange = (text as NSString).range(of: "Cancelation & Refund Policy")
        
        let location = gesture.location(in: termsLabel)
        let textStorage = NSTextStorage(attributedString: termsLabel.attributedText!)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: termsLabel.bounds.size)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = termsLabel.lineBreakMode
        textContainer.maximumNumberOfLines = termsLabel.numberOfLines
        
        let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if NSLocationInRange(index, termsRange) {
            openURL(URLs.termsUrl)
        } else if NSLocationInRange(index, privacyRange) {
            openURL(URLs.privacyUrl)
        }else if NSLocationInRange(index, cancelationRange) {
            openURL(URLs.cancellaionPolicyUrl)
        }
    }
}

extension MobileNumberViewController{
    @objc func dismissKeyboard(){
        view.endEditing(true)
        if mobileNumberTextField.text?.count ?? 0 == 4{
            mobileNumberTextField.text = ""
            mobileNumberTextField.tag = 0
        }
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let safeAreaBottom = view.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.signInButton.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - safeAreaBottom - 20))
                self.termsLabel.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - safeAreaBottom - 15))
                self.checkButton.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - safeAreaBottom - 15))
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.signInButton.transform = .identity  // Reset position
            self.termsLabel.transform = .identity
            self.checkButton.transform = .identity
        }
    }
}
