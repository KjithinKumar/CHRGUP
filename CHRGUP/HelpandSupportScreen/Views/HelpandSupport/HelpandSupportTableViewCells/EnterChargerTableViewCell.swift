//
//  EnterChargerTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 18/09/25.
//

import UIKit

protocol EnterChargerCellDelegate: AnyObject {
    func didTapScanQRCode(cell: EnterChargerTableViewCell)
}

class EnterChargerTableViewCell: UITableViewCell {
    
    static let identifier = "EnterChargerTableViewCell"
    
    weak var delegate : textFieldsdidChangeDelegate?
    weak var scanDelegate : EnterChargerCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var scanQRButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scanQRButton.layer.cornerRadius = 20
        scanQRButton.setTitle(AppStrings.Map.scanButtonTitle, for: .normal)
        scanQRButton.titleLabel?.font = FontManager.regular()
        scanQRButton.imageView?.tintColor = ColorManager.textColor
        scanQRButton.setTitleColor(ColorManager.textColor, for: .normal)
        scanQRButton.backgroundColor = ColorManager.secondaryBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configure(title : String,placeholder : String,delegate : textFieldsdidChangeDelegate, scanDelegate : EnterChargerCellDelegate){
        titleLabel.text = title
        titleLabel.font = FontManager.regular()
        titleLabel.textColor = ColorManager.textColor
        
        textField.backgroundColor = ColorManager.secondaryBackgroundColor
        textField.placeholder = placeholder
        textField.tintColor = ColorManager.primaryColor
        textField.textColor = ColorManager.primaryTextColor
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        self.delegate = delegate
        self.scanDelegate = scanDelegate

    }
    
    @IBAction func scanQRButtonPressed(_ sender: Any) {
        scanDelegate?.didTapScanQRCode(cell: self)
    }
    
    @objc func textFieldChanged(){
        delegate?.textFieldDidChange(in: self, newText: textField.text ?? "")
    }
    
}
