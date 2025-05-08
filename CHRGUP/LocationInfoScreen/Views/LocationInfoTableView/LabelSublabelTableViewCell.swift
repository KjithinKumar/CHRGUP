//
//  LabelSublabelTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 28/04/25.
//

import UIKit

class LabelSublabelTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    static let identifier = "LabelSublabelTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        titleLabel.textColor = ColorManager.placeholderColor
        titleLabel.font = FontManager.bold(size: 17)
        
        subTitleLabel.text = subtitle
        subTitleLabel.textColor = ColorManager.textColor
        subTitleLabel.font = FontManager.regular()
    }
    
}
