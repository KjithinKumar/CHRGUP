//
//  NoDataTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 23/09/25.
//

import UIKit

class NoDataTableViewCell: UITableViewCell {
    static let identifier = "NoDataTableViewCell"
    @IBOutlet weak var noDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noDataLabel.textColor = ColorManager.subtitleTextColor
        noDataLabel.font = FontManager.light()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
