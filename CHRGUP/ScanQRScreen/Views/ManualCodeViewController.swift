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
    @IBOutlet weak var connectorIdLabel: UILabel!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    var viewModel : ScanQrViewModelInterface?
    var connectorId = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        codeTextField.becomeFirstResponder()
    }
    
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        titleLabel.text = AppStrings.ScanQr.manualQrTitle
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.bold(size: 17)
        
        connectorIdLabel.text = AppStrings.ScanQr.connectorIdText
        connectorIdLabel.textColor = ColorManager.textColor
        connectorIdLabel.font = FontManager.regular()
        
        segmentedController.selectedSegmentTintColor = ColorManager.primaryColor
        
        codeTextField.backgroundColor = ColorManager.secondaryBackgroundColor
        codeTextField.layer.cornerRadius = 8
        codeTextField.layer.masksToBounds = true
        codeTextField.textColor = ColorManager.primaryTextColor
        codeTextField.tintColor = ColorManager.primaryColor
        codeTextField.font = FontManager.bold(size: 17)
        codeTextField.delegate = self
        codeTextField.autocapitalizationType = .allCharacters
        
        setButtonState(enable: false)
        submitButton.layer.cornerRadius = 20
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        submitButton.titleLabel?.font = FontManager.bold(size: 18)
        
        closeButton.tintColor = ColorManager.textColor
        configureNavBar()
    }
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
            connectorId = 1
             case 1:
            connectorId = 2
        default:
            break
        }
    }
    
    func configureNavBar(){
        navigationItem.title = "Enter Code"
        
        let barButton = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = barButton
    }
    func setButtonState(enable : Bool){
        if enable{
            submitButton.backgroundColor = ColorManager.primaryColor
            submitButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
            submitButton.isUserInteractionEnabled = true
        }else{
            submitButton.backgroundColor = ColorManager.secondaryBackgroundColor
            submitButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
            submitButton.isUserInteractionEnabled = false
        }
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.navigationController?.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func submitButtonPressed(_ sender: Any) {
        disableButtonWithActivityIndicator(submitButton)
        if let code = codeTextField.text?.replacingOccurrences(of: " ", with: ""){
            let payLoad = QRPayload(connectorId: connectorId, chargerId: code)
            viewModel?.fetchChargerDetails(id: code, connectorId: connectorId) { [weak self ]result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result{
                    case .success(let response):
                        if response.status{
                            if let data = response.data{
                                let startChargeVc = StartChargeViewController()
                                startChargeVc.viewModel = StartChargeViewModel(chargerInfo: data, networkManager: NetworkManager())
                                startChargeVc.payLoad = payLoad
                                self.navigationController?.setViewControllers([startChargeVc], animated: true)
                            }
                        }else{
                            self.enableButtonAndRemoveIndicator(self.submitButton)
                            self.codeTextField.text = ""
                            self.setButtonState(enable: false)
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
