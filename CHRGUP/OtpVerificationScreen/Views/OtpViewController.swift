//
//  OtpViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 01/03/25.
//

import UIKit


class OtpViewController: UIViewController {
    @IBOutlet weak var OtpTitleLabel: UILabel!
    @IBOutlet weak var otpSubtitleLabel: UILabel!
    
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpTextField5: UITextField!
    @IBOutlet weak var otpTextField6: UITextField!
    
    @IBOutlet weak var verifyButton: UIButton!
    
    @IBOutlet weak var resendOtpTextField: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var otpTextFields : [UITextField]!
    private var timer : Timer?
    private var secondsRemaining : Int = 30
    private var isResendEnabled : Bool = false
    var mobileNumber : String?
    private var lastBackPressedTime: TimeInterval = 0
    private var toastLabel: UILabel?
    
    var viewModel : OtpViewModelInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otpTextFields = [self.otpTextField1, self.otpTextField2, self.otpTextField3, self.otpTextField4, self.otpTextField5, self.otpTextField6]
        setUpUI()
        startTimer()
        configureNavBar()
        observeKeyboardNotifications()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.endEditing(true)
    }
    deinit {
        removeKeyboardNotifications()
    }
    
    @IBAction func verifyButtonPressed(_ sender: Any) {
        let otp = otpTextFields.compactMap { $0.text }.joined()
        guard let mobileNumber = mobileNumber else { return }
        debugPrint("Entered OTP: \(otp)")
        setVerifyButtonState(.verifying)
        viewModel?.verifyOtp(phoneNumber: mobileNumber, otp: otp){ message,result in
            if result{
                self.setVerifyButtonState(.verified)
                self.viewModel?.checkUserRegistration(phoneNumber: mobileNumber)
            }else{
                self.showToast(message: message)
                self.setVerifyButtonState(.verify)
            }
        }
        //self.viewModel?.checkUserRegistration(phoneNumber: mobileNumber)
    }
    
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        
        OtpTitleLabel.textColor = ColorManager.textColor
        OtpTitleLabel.font = FontManager.bold()
        OtpTitleLabel.text = AppStrings.Otp.title
        
        
        otpSubtitleLabel.textColor = ColorManager.subtitleTextColor
        otpSubtitleLabel.font = FontManager.regular()
        otpSubtitleLabel.text = AppStrings.Otp.subtitle + maskPhoneNumber(mobileNumber ?? "")
        
        resendOtpTextField.textColor = ColorManager.subtitleTextColor
        resendOtpTextField.font = FontManager.regular()
        resendOtpTextField.text = AppStrings.Otp.resendIn
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resendOtp))
        resendOtpTextField.addGestureRecognizer(tapGesture)
        resendOtpTextField.isUserInteractionEnabled = isResendEnabled
        
        
        verifyButton.backgroundColor = ColorManager.secondaryBackgroundColor
        verifyButton.layer.cornerRadius = 20
        verifyButton.tintColor = ColorManager.backgroundColor
        verifyButton.isEnabled = false
        setVerifyButtonState(.verify)
        
        setuptextFields()
        
        activityIndicator.isHidden = true
    }
    
    func configureNavBar(){
        let button = UIButton(type: .system)
        let backImage = UIImage(systemName: "chevron.left")?
            .applyingSymbolConfiguration(UIImage.SymbolConfiguration(weight: .bold))
        button.setImage(backImage, for: .normal)
        button.backgroundColor = .clear
        button.tintColor = ColorManager.buttonColorwhite
        button.contentHorizontalAlignment = .left
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
    }

    
}

extension OtpViewController : UITextFieldDelegate{
    func setuptextFields(){
        for i in otpTextFields{
            i.backgroundColor = ColorManager.secondaryBackgroundColor
            i.textColor = ColorManager.primaryColor
            i.tintColor = ColorManager.primaryColor
            i.keyboardType = .numberPad
            i.delegate = self
            i.layer.borderWidth = 1
            i.layer.borderColor = ColorManager.secondaryBackgroundColor.cgColor
            i.font = FontManager.bold(size: 17)
            i.layer.cornerRadius = 8
            i.layer.masksToBounds = true
            i.textContentType = .oneTimeCode
            i.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {return false}
        let isDeleting = string.isEmpty  // Detect backspace
        if let _ = string.rangeOfCharacter(from: .decimalDigits), string.count == otpTextFields.count {
            
            // Split and assign digits to respective text fields
            for (index, char) in string.enumerated() {
                otpTextFields[index].text = String(char)
            }
            
            checkIfOTPIsEntered()
            return false
        }
        
        if let currentIndex = otpTextFields.firstIndex(of: textField) {
            
            if isDeleting {
                if !text.isEmpty {
                    // If the field has text, just delete it
                    textField.text = ""
                    // Move to the previous field if empty and backspace is pressed
                    if currentIndex > 0 {
                        let previousTextField = otpTextFields[currentIndex - 1]
                        previousTextField.becomeFirstResponder() // Move cursor back
                    }
                    
                    return false
                }
            }
            if !text.isEmpty && !isDeleting {
                textField.text = string
                if currentIndex < otpTextFields.count - 1 {
                    otpTextFields[currentIndex + 1].becomeFirstResponder()
                }
                checkIfOTPIsEntered()
            }
            
            // Ensure only one character is entered per field
            if text.isEmpty && string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                textField.text = string
                
                // Move to the next field
                if currentIndex < otpTextFields.count - 1 {
                    otpTextFields[currentIndex + 1].becomeFirstResponder()
                }
                
                checkIfOTPIsEntered()
                return false
            }
        }
        
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkIfOTPIsEntered()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = ColorManager.primaryColor.cgColor
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Ensure text fields are filled in order
        if let index = otpTextFields.firstIndex(of: textField) {
            if index > 0 && otpTextFields[index - 1].text?.isEmpty == true {
                return false // Prevent editing if previous field is empty
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            textField.layer.borderColor = ColorManager.primaryColor.cgColor // Keep border color if text exists
        } else {
            textField.layer.borderColor = ColorManager.secondaryBackgroundColor.cgColor // Reset if empty
        }
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else { return }
        
        if let index = otpTextFields.firstIndex(of: textField) {
            // Ensure only one character is present
            textField.text = String(text.prefix(1))
            
            // Move to the next text field if not the last
            if index < otpTextFields.count - 1 {
                otpTextFields[index + 1].becomeFirstResponder()
            }
        }
        
        checkIfOTPIsEntered()
    }
}

extension OtpViewController{
    @objc func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    @objc func resendOtp(){
        if isResendEnabled{
            guard let mobileNumber = mobileNumber else { return }
            resendOtpTextField.textColor = ColorManager.subtitleTextColor
            startTimer()
            otpTextFields.forEach { $0.text = "" }
            setuptextFields()
            otpTextFields.first?.becomeFirstResponder()
            viewModel?.resendOtp(phoneNumber: mobileNumber){ result in
                if result == "OTP resent successfully"{
                    self.setVerifyButtonState(.verify)
                }else{
                    self.showToast(message: "Try again later")
                }
            }
        }
        
    }
    private func startTimer() {
        secondsRemaining = 30
        isResendEnabled = false
        resendOtpTextField.isUserInteractionEnabled = isResendEnabled
        updateCountdownLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
    }
    private func updateCountdown() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            updateCountdownLabel()
        } else {
            timer?.invalidate()
            resendOtpTextField.text = "Resend OTP"
            resendOtpTextField.textColor = ColorManager.primaryColor
            isResendEnabled = true
            resendOtpTextField.isUserInteractionEnabled = isResendEnabled
        }
    }
    private func updateCountdownLabel() {
        let normalText = "Resend OTP in "
        let boldText = "\(secondsRemaining)s"
        
        let attributedString = NSMutableAttributedString(string: normalText, attributes: [
            .font: FontManager.regular(size: 17),
            .foregroundColor: ColorManager.subtitleTextColor
        ])
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.bold(size: 18),
            .foregroundColor: ColorManager.subtitleTextColor
        ]
        
        let boldAttributedString = NSAttributedString(string: boldText, attributes: boldAttributes)
        
        attributedString.append(boldAttributedString)
        
        resendOtpTextField.attributedText = attributedString
        resendOtpTextField.textColor = ColorManager.subtitleTextColor
    }
    private func checkIfOTPIsEntered() {
        let isFilled = otpTextFields.allSatisfy { $0.text?.count == 1 }
        if isFilled {
            verifyButton.backgroundColor = ColorManager.primaryColor
            verifyButton.isEnabled = true
        }else{
            verifyButton.isEnabled = false
            verifyButton.backgroundColor = ColorManager.secondaryBackgroundColor
        }
    }
    
}

extension OtpViewController{
    @objc override func dismissKeyboard(){
        super.dismissKeyboard()
    }
    @objc override func moveViewForKeyboard(yOffset: CGFloat) {
        self.verifyButton.transform = CGAffineTransform(translationX: 0, y: yOffset)
        self.activityIndicator.transform = CGAffineTransform(translationX: 0, y: yOffset)
    }
    
    func setVerifyButtonState(_ state: VerifyState) {
        DispatchQueue.main.async {
            let title: String
            let attributes: [NSAttributedString.Key: Any] = [
                .font: FontManager.bold(size: 17),
                .foregroundColor: ColorManager.backgroundColor
            ]
            
            switch state {
            case .verify:
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                title = AppStrings.Otp.verifyButtonTitle
                self.verifyButton.isUserInteractionEnabled = true
            case .verifying:
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
                self.verifyButton.isUserInteractionEnabled = false
                title = ""
            case .verified:
                title = AppStrings.Otp.verifiedButtonTitle
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                //self.movetoCheckUser()
            }
            
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            self.verifyButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }
    
    func maskPhoneNumber(_ phoneNumber: String) -> String {
        guard phoneNumber.count >= 4 else { return phoneNumber } // Ensure the number is valid
        
        let lastFour = phoneNumber.suffix(4) // Get last 4 digits
        let maskedPart = String(repeating: "*", count: 6) // Mask remaining
        return maskedPart + lastFour
    }
    @objc func handleBackButton() {
        let currentTime = Date().timeIntervalSince1970
        
        if currentTime - lastBackPressedTime < 2 {
            backButtonTapped()
        } else {
            showToast(message: AppStrings.Otp.toastMessage)
        }
        
        lastBackPressedTime = currentTime
    }
    private func showToast(message: String) {
        toastLabel?.removeFromSuperview()
        
        let toast = UILabel()
        toast.text = message
        toast.textAlignment = .center
        toast.backgroundColor = ColorManager.secondaryBackgroundColor.withAlphaComponent(0.8)
        toast.textColor = ColorManager.subtitleTextColor
        toast.layer.cornerRadius = 20
        toast.clipsToBounds = true
        toast.frame = CGRect(x: 50, y: self.view.safeAreaInsets.top+10 , width: self.view.frame.width - 100, height: 40)
        
        self.view.addSubview(toast)
        toastLabel = toast
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            toast.removeFromSuperview()
        }
    }
}

extension OtpViewController : OtpViewModelDelegate {
    func didRequireGoogleSignIn() {
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem?.isHidden = true
            GoogleSignInHelper.shared.signIn(with: self) { result in
                switch result{
                case .success(let newuser) :
                    let vehicleVc = UserVehicleInfoViewController()
                    vehicleVc.viewModel = UserVehicleInfoViewModel(delegate: vehicleVc, networkManager: NetworkManager())
                    vehicleVc.userData = newuser
                    vehicleVc.userData?.phoneNumber = self.mobileNumber ?? ""
                    self.navigationController?.pushViewController(vehicleVc, animated: true)
                case .failure(let error):
                    self.navigationItem.leftBarButtonItem?.isHidden = false
                    debugPrint(error.localizedDescription)
                    self.setVerifyButtonState(.verify)
                }
            }
        }
    }
    
    func didRegisterSuccessfully(userProfile: UserProfile, sessionData: SessionData?) {
        debugPrint("fetched User Profile from API - \(userProfile)")
        debugPrint("fetched session Data from API - \(String(describing: sessionData))")
        debugPrint("checking user from userdefaults - \(String(describing: UserDefaultManager.shared.getUserProfile()))")
        debugPrint("checking JWTToken from userdefaults - \(String(describing: UserDefaultManager.shared.getJWTToken()))")
    }
    
    func didFailToRegister(error: String) {
        debugPrint(error.description)
    }
}
