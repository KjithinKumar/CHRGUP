//
//  SideMenuTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/03/25.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var LeftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    static let identifier = "SideMenuTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configureCell(title: String,leftImage : String) {
        self.LeftImageView.image = UIImage(systemName: leftImage)
        self.titleLabel.text = title
        LeftImageView.tintColor = ColorManager.textColor
        rightImageView.tintColor = ColorManager.textColor
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.regular()
    }
    
}
