//
//  TicketStatusTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 06/05/25.
//

import UIKit

class TicketStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    static let identifier = "TicketStatusTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(title: String){
        titleLabel.text = title
        titleLabel.font = FontManager.regular(size: 14)
        titleLabel.textColor = ColorManager.subtitleTextColor
    }
}
