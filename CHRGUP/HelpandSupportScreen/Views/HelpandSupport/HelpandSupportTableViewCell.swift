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
        
        settingsImageView.tintColor = ColorManager.primaryColor
        self.type = type
        settingTitleLabel.text = title
        settingsImageView.image = UIImage(systemName: image)
        stackView.layer.cornerRadius = 10
        stackView.backgroundColor = ColorManager.secondaryBackgroundColor
    }
    
}
