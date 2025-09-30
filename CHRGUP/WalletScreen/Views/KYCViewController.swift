//
//  KYCViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/09/25.
//

import UIKit

class KYCViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var documentTypeTitleLabel: UILabel!
    @IBOutlet weak var documentTypeTextField: UITextField!
    @IBOutlet weak var DocumentNumberTitleLabel: UILabel!
    @IBOutlet weak var documentNumberTextField: UITextField!
    @IBOutlet weak var dobTitleLabel: UILabel!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var proceedButton: UIButton!
    var viewModel : KYCViewModelInterface?
    private let pickerView = UIPickerView()
    
    var selectedDocumentType : DocumentTypes?
    var selectedDocumentNumber : String?
    var selectedDob : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
        observeKeyboardNotifications()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.reloadAllComponents()
        documentTypeTextField.delegate = self
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    @IBAction func proceedButtonPressed(_ sender: Any) {
    }
    
    func setUpUi(){
        navigationItem.title = AppStrings.KYC.Title
        
        view.backgroundColor = ColorManager.backgroundColor
        
        titleLabel.text = AppStrings.KYC.kycTitle
        titleLabel.font = FontManager.bold(size: 17)
        titleLabel.textColor = ColorManager.textColor
        
        subTitleLabel.text = AppStrings.KYC.kycSubtTitle
        subTitleLabel.font = FontManager.regular()
        subTitleLabel.textColor = ColorManager.subtitleTextColor
        
        documentTypeTitleLabel.text = AppStrings.KYC.documentTypeTitle
        documentTypeTitleLabel.font = FontManager.regular()
        documentTypeTitleLabel.textColor = ColorManager.textColor
        
        documentTypeTextField.backgroundColor = ColorManager.secondaryBackgroundColor
        documentTypeTextField.rightView = dropDownImageView(with: "chevron.down")
        documentTypeTextField.rightViewMode = .always
        documentTypeTextField.inputView = pickerView
        documentTypeTextField.textColor = ColorManager.primaryTextColor
        documentTypeTextField.tintColor = .clear
        documentTypeTextField.font = FontManager.regular()
        documentTypeTextField.placeholder = AppStrings.KYC.documentTypePlaceHolder
        
        DocumentNumberTitleLabel.text = AppStrings.KYC.documentNumber
        DocumentNumberTitleLabel.font = FontManager.regular()
        DocumentNumberTitleLabel.textColor = ColorManager.textColor
        
        documentNumberTextField.backgroundColor = ColorManager.secondaryBackgroundColor
        documentNumberTextField.textColor = ColorManager.primaryTextColor
        documentNumberTextField.tintColor = ColorManager.primaryTextColor
        documentNumberTextField.font = FontManager.regular()
        documentNumberTextField.placeholder = AppStrings.KYC.documentNumberPlaceHolder
        documentNumberTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        
        dobTitleLabel.text = AppStrings.KYC.DOBTitle
        dobTitleLabel.font = FontManager.regular()
        dobTitleLabel.textColor = ColorManager.textColor
        
        dobTextField.backgroundColor = ColorManager.secondaryBackgroundColor
        dobTextField.textColor = ColorManager.primaryTextColor
        dobTextField.tintColor = .clear
        dobTextField.font = FontManager.regular()
        dobTextField.placeholder = AppStrings.KYC.dobPlaceHolder
        dobTextField.rightView = dropDownImageView(with: "calendar")
        dobTextField.rightViewMode = .always
        let datePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 20, y: 50, width: view.frame.width, height: 200)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        dobTextField.inputView = datePicker
        dobTextField.tintColor = .clear
        
        proceedButton.setTitle(AppStrings.KYC.proceedButton, for: .normal)
        proceedButton.titleLabel?.font = FontManager.bold(size: 17)
        proceedButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        proceedButton.isEnabled = false
        proceedButton.backgroundColor = ColorManager.secondaryBackgroundColor
        proceedButton.layer.cornerRadius = 20
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    func dropDownImageView(with imageName : String) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30)) // Adjust width for spacing
        let imageView = UIImageView(image: UIImage(systemName: imageName ))
        
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorManager.textColor
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 30) // Add left padding inside the container
        
        containerView.addSubview(imageView)
        return containerView
    }
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        dobTextField.text = formatter.string(from: sender.date)
        selectedDob = formatter.string(from: sender.date)
        validateProceedButton()
    }
    @objc func textFieldChanged(){
        selectedDocumentNumber = documentNumberTextField.text
        validateProceedButton()
    }
}
extension KYCViewController{
    override func adjustForKeyboard(showing: Bool, inset: CGFloat) {
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom  = inset
    }
}
extension KYCViewController : UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel?.documentTypes.count ?? 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel?.documentTypes[row].displayName
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectValue = viewModel?.documentTypes[row]
        documentTypeTextField.text = selectValue?.displayName
        selectedDocumentType = selectValue
        DocumentNumberTitleLabel.text = "\(selectValue?.displayName ?? "Document") Number"
        validateProceedButton()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if selectedDocumentType == nil{
            if textField == documentTypeTextField{
                let selectedValue = viewModel?.documentTypes.first?.displayName
                textField.text = selectedValue
                selectedDocumentType = viewModel?.documentTypes.first
                DocumentNumberTitleLabel.text = "\(selectedValue ?? "Document") Number"
            }
        }
        validateProceedButton()
    }
    func validateProceedButton() {
        guard
            let dob = selectedDob, !dob.isEmpty,
            let _ = selectedDocumentType, // just checking not nil
            let documentNumber = selectedDocumentNumber, !documentNumber.isEmpty
        else {
            proceedButton.isEnabled = false
            proceedButton.backgroundColor = ColorManager.secondaryBackgroundColor
            proceedButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
            return
        }
        proceedButton.isEnabled = true
        proceedButton.backgroundColor = ColorManager.primaryColor
        proceedButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
    }
}
