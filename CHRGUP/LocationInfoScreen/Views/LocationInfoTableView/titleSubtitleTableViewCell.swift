//
//  titleSubtitleTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/03/25.
//

import UIKit

class titleSubtitleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    static let identifier = "titleSubtitleTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        titleLabel.textColor = ColorManager.placeholderColor
        titleLabel.font = FontManager.bold(size: 17)
        
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = ColorManager.textColor
        subtitleLabel.font = FontManager.regular()
        
    }
    
}
