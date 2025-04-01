//
//  EditProfileTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 29/03/25.
//

import UIKit

protocol EditProfileTableViewCellDelegate : AnyObject {
    func didChangeText(text : String, cell : EditProfileTableViewCell)
}

class EditProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var backStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var rightImageView: UIImageView!
    static let identifier: String = "EditProfileTableViewCell"
    
    @IBOutlet weak var backView: UIView!
    
    var pickerView : UIPickerView?
    weak var delegate : EditProfileTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(type : TextFieldType, userdata : UserProfile, delegate : EditProfileTableViewCellDelegate?){
        textField.delegate = self
        self.delegate = delegate
        
        textField.layer.borderColor = ColorManager.primaryColor.cgColor
        createToolbar(for: textField)
        rightImageView.tintColor = ColorManager.textColor
        
        
        backView.backgroundColor = ColorManager.backgroundColor
        backView.layer.cornerRadius = 8
        
        backStackView.backgroundColor = ColorManager.backgroundColor
        
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.regular()
        
        textField.textColor = ColorManager.primaryColor
        textField.backgroundColor = ColorManager.secondaryBackgroundColor
        textField.font = FontManager.regular()
        
        textField.layer.cornerRadius = 8
        
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingDidEnd)
        switch type {
        case .textField(let title, let placeholder):
            titleLabel.text = title
            textField.placeholder = placeholder
            if title == AppStrings.EditProfile.firstNameText{
                textField.text = userdata.firstName
            }else if title == AppStrings.EditProfile.lastnameText{
                textField.text = userdata.lastName
            }else if title == AppStrings.EditProfile.emailText{
                textField.text = userdata.email
                textField.isEnabled = false
                textField.textColor = ColorManager.primaryColor.withAlphaComponent(0.5)
            }
            textField.tintColor = ColorManager.primaryColor
        case .dropDown(title: let title, placeholder: let placeholder):
            titleLabel.text = title
            textField.placeholder = placeholder
            rightImageView.image = UIImage(systemName: "chevron.down")
            pickerView = UIPickerView()
            pickerView?.delegate = self
            pickerView?.dataSource = self
            textField.inputView = pickerView
            textField.tintColor = .clear
            textField.text = userdata.gender
            
        case .datePicker(title: let title, placeholder: let placeholder):
            titleLabel.text = title
            textField.placeholder = placeholder
            rightImageView.image = UIImage(systemName: "calendar")
            let datePicker = UIDatePicker()
            datePicker.frame = CGRect(x: 20, y: 100, width: frame.width, height: 200)
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.maximumDate = Date()
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            textField.inputView = datePicker
            textField.tintColor = .clear
            textField.text = userdata.dob
        }
        if textField.text != "" { textField.layer.borderWidth = 1} else {textField.layer.borderWidth = 0}
    }
}

extension EditProfileTableViewCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.layer.borderWidth = 0
        }
    }
    @objc func textFieldChanged(){
        delegate?.didChangeText(text: textField.text ?? "", cell: self)
    }
}
extension EditProfileTableViewCell : UIPickerViewDelegate,UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Male"
        }else{
            return "Female"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            textField.text = "Male"
        }else{
            textField.text = "Female"
        }
    }
    private func createToolbar(for textField: UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    @objc func donePressed(){
        textField.resignFirstResponder()
    }
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        textField.text = formatter.string(from: sender.date)
    }
}
