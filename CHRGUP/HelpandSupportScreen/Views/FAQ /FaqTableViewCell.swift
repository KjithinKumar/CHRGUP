//
//  FaqTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/03/25.
//

import UIKit

class FaqTableViewCell: UITableViewCell {

    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    static let identifier = "FaqTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(question: String, answer: String, isExpanded: Bool) {
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
        backView.layer.cornerRadius = 8
        
        questionLabel.text = "\(question)"
        questionLabel.font = FontManager.regular()
        questionLabel.textColor = ColorManager.textColor
        questionLabel.backgroundColor = .clear
        
        answerLabel.isHidden = !isExpanded
        answerLabel.text = "\(answer)"
        answerLabel.font = FontManager.light()
        answerLabel.textColor = ColorManager.subtitleTextColor
        answerLabel.backgroundColor = .clear
        
        chevronImageView.tintColor = ColorManager.textColor
        
        if isExpanded {
            chevronImageView.image = UIImage(systemName: "chevron.up")
        }else{
            chevronImageView.image = UIImage(systemName: "chevron.down")
        }
        
    }
    
    func setShimmer(isShimmer: Bool) {
        if isShimmer {
            backView.backgroundColor = ColorManager.secondaryBackgroundColor
            backView.layer.cornerRadius = 8
            questionLabel.backgroundColor = .label.withAlphaComponent(0.5)
            questionLabel.textColor = .clear
            questionLabel.layer.cornerRadius = 8
            answerLabel.backgroundColor = .label.withAlphaComponent(0.5)
            answerLabel.textColor = .clear
            answerLabel.layer.cornerRadius = 8
            questionLabel.startShimmering()
            answerLabel.startShimmering()
            stackView.backgroundColor = .clear
            contentView.backgroundColor = ColorManager.backgroundColor
        }else{
            questionLabel.stopShimmering()
            answerLabel.stopShimmering()
        }
    }
}
