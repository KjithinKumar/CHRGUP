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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var TermsStackView: UIStackView!
    
    var authMode: AuthMode = .SignIn
    private var isChecked : Bool = false
    private var isValidMobileNumber: Bool = false
    private var isSendingOtp : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureUi()
        configureNavBar()
        observeKeyboardNotifications()
    }
    override func viewDidAppear(_ animated: Bool) {
        mobileNumberTextField.becomeFirstResponder()
    }
    deinit {
        removeKeyboardNotifications()
    }
    
    override func viewWillDisappear (_ animated: Bool) {
        view.endEditing(true)
        activityIndicator.isHidden = true
        signInButton.isEnabled = true
        isSendingOtp = false
        signInButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
    }
    
    func configureAuth() {
        switch authMode {
        case .SignIn:
            welcomeLabel.text = AppStrings.Auth.welcomBackTitle
            welcomeSubtitleLabel.text = AppStrings.Auth.welcomeSubtitle
            signInButton.setTitle(AppStrings.Auth.signInButtonTitle, for: .normal)
            signInButton.titleLabel?.font = FontManager.bold(size: 17)
            signInButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        

        case .SignUp:
            welcomeLabel.text = AppStrings.Auth.welcomeTitle
            welcomeSubtitleLabel.text = AppStrings.Auth.welcomeSubtitle
            signInButton.setTitle(AppStrings.Auth.signUpButtonTitle, for: .normal)
            signInButton.titleLabel?.font = FontManager.bold(size: 17)
            signInButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
            
        }
    }
    func configureUi(){
        view.backgroundColor = ColorManager.backgroundColor
        
        welcomeLabel.font = FontManager.bold()
        welcomeLabel.textColor = ColorManager.textColor
        
        welcomeSubtitleLabel.textColor = ColorManager.subtitleTextColor
        welcomeSubtitleLabel.font = FontManager.regular()
        
        mobileNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        mobileNumberTextField.delegate = self
        mobileNumberTextField.backgroundColor = ColorManager.secondaryBackgroundColor
        mobileNumberTextField.layer.cornerRadius = 8
        mobileNumberTextField.layer.masksToBounds = true
        mobileNumberTextField.textColor = ColorManager.primaryColor
        mobileNumberTextField.tintColor = ColorManager.primaryColor
        mobileNumberTextField.font = FontManager.bold(size: 17)
        mobileNumberTextField.keyboardType = .numberPad
        mobileNumberTextField.tag = 0
        mobileNumberTextField.layer.borderWidth = 1
        mobileNumberTextField.layer.borderColor = ColorManager.secondaryBackgroundColor.cgColor

        mobileNumberLabel.textColor = ColorManager.textColor
        mobileNumberLabel.font = FontManager.regular()
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.backgroundColor = ColorManager.secondaryBackgroundColor
        signInButton.layer.cornerRadius = 20
        signInButton.isEnabled = false
        
        activityIndicator.isHidden = true
        
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
        checkButton.layer.cornerRadius = 10
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    func configureNavBar() {
        
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
        if isChecked && isValidMobileNumber{
            signInButton.isEnabled = true
            signInButton.backgroundColor = ColorManager.primaryColor

        }else{
            signInButton.isEnabled = false
            signInButton.backgroundColor = ColorManager.secondaryBackgroundColor

        }
    }
    @IBAction func signInButtonTapped(_ sender: Any) {
        isSendingOtp = true
        if isSendingOtp {
            signInButton.isEnabled = false
            signInButton.setTitleColor(ColorManager.textColor, for: .normal)
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        let otpVc = OtpViewController()
        let mobileNumber = mobileNumberTextField.text!
        let validNumber = mobileNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let number = validNumber.replacingOccurrences(of: " ", with: "")
        otpVc.mobileNumber = number
        let viewModel = OtpViewModel(delegate: otpVc, networkManager: NetworkManager())
        otpVc.viewModel = viewModel
        
//        TwilioHelper.sendVerificationCode(to: number) { isValid in
//            guard (isValid == nil) else {
//                self.showAlert(title: "Error", message: "Please check the number you have entered or try again later")
//                self.signInButton.isEnabled = true
//                self.signInButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
//                self.activityIndicator.isHidden = true
//                return
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.navigationController?.pushViewController(otpVc, animated: true)
//            }
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.pushViewController(otpVc, animated: true)
        }
    }
}

extension MobileNumberViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if mobileNumberTextField.tag == 0{
            textField.text = AppStrings.MobileExtension.Ind
            textField.layer.borderColor = ColorManager.primaryColor.cgColor
            textField.tag = 1
        }
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
    @objc override func dismissKeyboard(){
        super.dismissKeyboard()
        if mobileNumberTextField.text?.count ?? 0 == 4{
            mobileNumberTextField.text = ""
            mobileNumberTextField.layer.borderColor = ColorManager.secondaryBackgroundColor.cgColor
            mobileNumberTextField.tag = 0
        }
    }
    override func moveViewForKeyboard(yOffset: CGFloat) {
        signInButton.transform = CGAffineTransform(translationX: 0, y: yOffset)
        activityIndicator.transform = CGAffineTransform(translationX: 0, y: yOffset)
//        termsLabel.transform = CGAffineTransform(translationX: 0, y: yOffset + 5)
//        checkButton.transform = CGAffineTransform(translationX: 0, y: yOffset + 5)
        TermsStackView.transform = CGAffineTransform(translationX: 0, y: yOffset + 5)
    }
}
