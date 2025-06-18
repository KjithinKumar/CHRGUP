//
//  SubjectTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 29/04/25.
//

import UIKit

class SubjectTableViewCell: UITableViewCell {
    
    static let identifier = "SubjectTableViewCell"
    
    weak var delegate : textFieldsdidChangeDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subjectTextfield: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func configure(title: String,placeHolder : String, delegate : textFieldsdidChangeDelegate?){
        self.delegate = delegate
        
        titleLabel.text = title
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.regular()
        
        subjectTextfield.placeholder = placeHolder
        subjectTextfield.backgroundColor = ColorManager.secondaryBackgroundColor
        subjectTextfield.tintColor = ColorManager.primaryColor
        subjectTextfield.textColor = ColorManager.primaryTextColor
        subjectTextfield.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    @objc func textFieldChanged(){
        delegate?.textFieldDidChange(in: self, newText: subjectTextfield.text ?? "")
    }
}
