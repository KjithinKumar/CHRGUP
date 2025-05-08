//
//  CategoryDropDownTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 30/04/25.
//

import UIKit

class CategoryDropDownTableViewCell: UITableViewCell {

    static let identifier = "CategoryDropDownTableViewCell"
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.regular(size: 14)
        
        backView.layer.cornerRadius = 8
        backView.clipsToBounds = true
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
    }
    
    
}
