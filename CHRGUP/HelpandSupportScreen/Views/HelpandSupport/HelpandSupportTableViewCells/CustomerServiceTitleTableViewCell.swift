//
//  CustomerServiceTitleTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 29/04/25.
//

import UIKit

class CustomerServiceTitleTableViewCell: UITableViewCell {

    static let identifier = "CustomerServiceTitleTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title : String, subtitle : String){
        titleLabel.text = title
        titleLabel.font = FontManager.bold(size: 18)
        titleLabel.textColor = ColorManager.primaryColor
        
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = ColorManager.subtitleTextColor
        subtitleLabel.font = FontManager.regular(size: 14)
    }
}
