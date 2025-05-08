//
//  HelpandSupportTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/03/25.
//

import UIKit

protocol HelpandSupportDelegate : AnyObject {
    func didSelectHelpandSupport(type : HelpAndSupportType)
}

class HelpandSupportTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingsImageView: UIImageView!
    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backView: UIView!
    
    static let identifier = "HelpandSupportTableViewCell"
    private var type : HelpAndSupportType?
    weak var delegate : HelpandSupportDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(title : String, image : String, type : HelpAndSupportType,delegate : HelpandSupportDelegate){
        
        settingsImageView.tintColor = ColorManager.textColor
        self.type = type
        settingTitleLabel.textColor = ColorManager.textColor
        settingTitleLabel.text = title
        settingsImageView.image = UIImage(systemName: image)
        backView.layer.cornerRadius = 10
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
        
    }
    
}
