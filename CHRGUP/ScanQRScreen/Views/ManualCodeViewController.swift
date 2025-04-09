//
//  ManualCodeViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 08/04/25.
//

import UIKit

class ManualCodeViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backStackView: UIStackView!
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel : ScanQrViewModelInterface?
    var onCodeScanned: ((ChargerLocationData) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        titleLabel.text = AppStrings.ScanQr.manualQrTitle
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.bold(size: 17)
        
        codeTextField.backgroundColor = ColorManager.secondaryBackgroundColor
        codeTextField.layer.cornerRadius = 8
        codeTextField.layer.masksToBounds = true
        codeTextField.textColor = ColorManager.primaryColor
        codeTextField.tintColor = ColorManager.primaryColor
        codeTextField.font = FontManager.bold(size: 17)
        codeTextField.delegate = self
        codeTextField.becomeFirstResponder()
        codeTextField.autocapitalizationType = .allCharacters
        
        setButtonState(enable: false)
        submitButton.layer.cornerRadius = 20
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        submitButton.titleLabel?.font = FontManager.bold(size: 18)
        
        closeButton.tintColor = ColorManager.textColor
    }
    func setButtonState(enable : Bool){
        if enable{
            submitButton.backgroundColor = ColorManager.primaryColor
            submitButton.isUserInteractionEnabled = true
        }else{
            submitButton.backgroundColor = ColorManager.secondaryBackgroundColor
            submitButton.isUserInteractionEnabled = false
        }
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func submitButtonPressed(_ sender: Any) {
        if let code = codeTextField.text?.replacingOccurrences(of: " ", with: ""){
            viewModel?.fetchChargerDetails(id: code) { [weak self ]result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result{
                    case .success(let response):
                        if response.status{
                            if let data = response.data{
                                self.onCodeScanned?(data)
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                            }
                        }else{
                            self.showAlert(title: "Error", message: response.message)
                        }
                    case .failure(let error):
                        AppErrorHandler.handle(error, in: self)
                    }
                }
            }
        }
    }
}
extension ManualCodeViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string.uppercased())
        let rawText = newText.replacingOccurrences(of: "[^A-Z0-9]", with: "", options: .regularExpression)
//        if rawText.count > 10 { return false }
        var formatted = ""
        for (index, char) in rawText.enumerated() {
            if index != 0 && index % 1 == 0 {
                formatted.append("  ")
            }
            formatted.append(char)
        }
        textField.text = formatted
        setButtonState(enable: rawText.count >= 1)
        
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        codeTextField.layer.borderWidth = 1
        codeTextField.layer.borderColor = ColorManager.primaryColor.cgColor
    }
}
