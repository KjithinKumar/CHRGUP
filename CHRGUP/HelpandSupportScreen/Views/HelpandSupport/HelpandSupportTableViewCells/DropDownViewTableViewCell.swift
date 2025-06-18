//
//  DropDownViewTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 29/04/25.
//

import UIKit

class DropDownViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valuetextField: UITextField!
    static let identifier = "DropDownViewTableViewCell"
    @IBOutlet weak var dropDownImageView: UIImageView!
    
    var type : HelpAndSupportDataModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(title: String, placeholder : String, image : String){
        
        titleLabel.text = title
        titleLabel.font = FontManager.regular()
        titleLabel.textColor = ColorManager.textColor
        
        valuetextField.backgroundColor = ColorManager.secondaryBackgroundColor
        valuetextField.placeholder = placeholder
        valuetextField.tintColor = .clear
        valuetextField.isUserInteractionEnabled = false
        valuetextField.textColor = ColorManager.primaryTextColor
        
        dropDownImageView.image = UIImage(systemName: image)
        dropDownImageView.tintColor = ColorManager.textColor
    }
    func setDropdownValue(_ value: String) {
        valuetextField.text = value
    }
}
