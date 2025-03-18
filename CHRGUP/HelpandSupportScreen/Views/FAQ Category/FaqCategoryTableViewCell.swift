//
//  FaqCategoryTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/03/25.
//

import UIKit

class FaqCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var stackeView: UIStackView!
    
    static let identifier : String = "FaqCategoryTableViewCell"
    var indexpath : IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title : String,indexpath : IndexPath ){
        categoryLabel.text = title
        
        rightImageView.tintColor = ColorManager.textColor
        rightImageView.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        
        self.indexpath = indexpath

    }
    func setShimmering(isShimmering : Bool){
        if isShimmering{
            
            stackeView.backgroundColor = ColorManager.secondaryBackgroundColor
            stackeView.layer.cornerRadius = 10
            categoryLabel.backgroundColor = .white
            categoryLabel.layer.cornerRadius = 8
            categoryLabel.textColor = .clear
            categoryLabel.startShimmering()
            rightImageView.isHidden = true
        }else{
            categoryLabel.backgroundColor = .clear
            categoryLabel.stopShimmering()
            rightImageView.isHidden = false
            categoryLabel.font = FontManager.regular()
            categoryLabel.textColor = ColorManager.textColor
            
        }
    }
}
