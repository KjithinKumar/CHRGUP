//
//  SearchTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 02/04/25.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var recentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backStackView: UIStackView!
    
    static let identifier = "SearchTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.backgroundColor = ColorManager.backgroundColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        titleLabel.updateShimmerLayout()
        subtitleLabel.updateShimmerLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setShimmering(isShimmering: Bool){
        if isShimmering{
            recentImageView.startShimmering()
            recentImageView.tintColor = .white
            
            titleLabel.textColor = .white
            titleLabel.backgroundColor = .white
            titleLabel.startShimmering()
            titleLabel.layer.cornerRadius = 8
            
            subtitleLabel.textColor = .white
            subtitleLabel.backgroundColor = .white
            subtitleLabel.startShimmering()
            subtitleLabel.layer.cornerRadius = 8
        }else{
            recentImageView.stopShimmering()
    
            titleLabel.stopShimmering()
            
            subtitleLabel.stopShimmering()
            
            configureUI()
            
        }
    }
    func configure(chargerLocation : ChargerLocation,searchText : String,recents : Bool){
        configureUI()
        
        titleLabel.attributedText = highlightText(fullText: chargerLocation.locationName, searchText: searchText)
        
        subtitleLabel.attributedText = highlightText(fullText: chargerLocation.address, searchText: searchText)
        subtitleLabel.font = FontManager.light()
        if recents{
            recentImageView.image = UIImage(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
        }else{
            recentImageView.image = UIImage(systemName: "location")
        }
    }
    func configureUI(){
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.regular()
        titleLabel.backgroundColor = .clear
        
        subtitleLabel.textColor = ColorManager.subtitleTextColor
        subtitleLabel.font = FontManager.light()
        subtitleLabel.backgroundColor = .clear
        
        recentImageView.tintColor = ColorManager.textColor
        recentImageView.backgroundColor = .clear
        
    }
    private func highlightText(fullText: String, searchText: String?) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)
        guard let searchText = searchText, !searchText.isEmpty else {
            return attributedString
        }
        let range = (fullText as NSString).range(of: searchText, options: .caseInsensitive)
        if range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: ColorManager.primaryColor.cgColor, range: range) // Change text color
            attributedString.addAttribute(.font, value: FontManager.bold(size: 17), range: range) // Make it bold
        }
        return attributedString
    }
}
