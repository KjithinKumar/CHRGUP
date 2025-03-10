//
//  DropdownTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 07/03/25.
//

import UIKit

enum UserVehicleInfoCellType : Equatable,Hashable{
    case dropdown(dropdownType : DropdownType,title : String,placeHolder : String)
    case textField(title : String,placeHolder : String)
}
enum DropdownType{
    case VehicleType
    case VehicleMake
    case VehicleModel
    case VehicleVariant
}

protocol UserVehicleInfoCellDelegate: AnyObject {
    func getPickerData(for type: UserVehicleInfoCellType) -> [String]
    func didSelectValue(_ value: String, for type: UserVehicleInfoCellType)
    func enableNextField(after type: UserVehicleInfoCellType)
}


class DropdownTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    static let identifier = "dropDownCell"

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var spaceViewTwo: UIView!
    @IBOutlet weak var spaceView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate : UserVehicleInfoCellDelegate?
    //private var pickerData: [String] = []
    private var cellType: UserVehicleInfoCellType?

    private let pickerView = UIPickerView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(with type: UserVehicleInfoCellType,delegate : UserVehicleInfoCellDelegate, selectedValue: String?,isEnabled: Bool) {
        
        label.textColor = ColorManager.textColor
        label.font = FontManager.regular()
        
        spaceView.backgroundColor = ColorManager.backgroundColor
        spaceViewTwo.backgroundColor = ColorManager.backgroundColor
        stackView.backgroundColor = ColorManager.backgroundColor
        
        self.delegate = delegate
        self.cellType = type
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.reloadAllComponents()
        
        label.backgroundColor = ColorManager.backgroundColor
        textField.delegate = self
        textField.backgroundColor = ColorManager.secondaryBackgroundColor
        textField.textColor = ColorManager.primaryColor
        textField.tintColor = ColorManager.primaryColor
        textField.font = FontManager.regular()
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 8
        
        if let savedValue = selectedValue {
            textField.text = savedValue
        } else {
            textField.text = nil
        }
        textField.isUserInteractionEnabled = isEnabled // ✅ Enable/Disable Field
        textField.alpha = isEnabled ? 1.0 : 0.5 // Dim when disabled
        
        switch type {
        case .dropdown(_,let title,let placeholder):
            label.text = title
            textField.placeholder = placeholder
            textField.inputView = pickerView // Set picker for dropdowns
            createToolbar(for: textField)
            //addDropdownIcon()
            textField.rightView = dropDownImageView()
            textField.rightViewMode = .always
            pickerView.reloadAllComponents()
        case .textField(let title, let placeholder):
            label.text = title
            textField.placeholder = placeholder
            textField.inputView = nil // Normal keyboard
            textField.rightView = nil
            textField.rightViewMode = .never
            
            
        }
    }
    func dropDownImageView() -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30)) // Adjust width for spacing
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorManager.textColor
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 30) // Add left padding inside the container
        
        containerView.addSubview(imageView)
        return containerView
    }
//    func addDropdownIcon(){
//        let dropdownImageView = dropDownImageView()
//        textField.addSubview(dropdownImageView)
//        dropdownImageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            dropdownImageView.trailingAnchor.constraint(equalTo: textField.trailingAnchor,constant: -10),
//            dropdownImageView.topAnchor.constraint(equalTo: textField.topAnchor),
//            dropdownImageView.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
//            
//        ])
//    }
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
}

extension DropdownTableViewCell : UIPickerViewDelegate,UIPickerViewDataSource  {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let type = cellType else { return 0 }
        return delegate?.getPickerData(for: type).count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let type = cellType else { return nil }
        return delegate?.getPickerData(for: type)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let type = cellType, let pickerData = delegate?.getPickerData(for: type) else { return }
        let selectedValue = pickerData[row]
        textField.text = selectedValue
        delegate?.didSelectValue(selectedValue, for: type)
        delegate?.enableNextField(after: type)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = ColorManager.primaryColor.cgColor
        guard let type = cellType, let pickerData = delegate?.getPickerData(for: type) else { return }
        if textField.text == "" {
            let selectedValue = pickerData.first
            textField.text = selectedValue
            delegate?.didSelectValue(selectedValue ?? "", for: type)
            delegate?.enableNextField(after: type)
        }
    }
}
