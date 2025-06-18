//
//  HeaderTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/04/25.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var chargerIdTitleLabel: UILabel!
    @IBOutlet weak var chargeridLabel: UILabel!
    
    static let identifier = "HeaderTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(headerDetails : headerModel){
        if headerDetails.type == "DC"{
            typeImageView.image = UIImage(named: "dc")
        }else{
            typeImageView.image = UIImage(named: "ac")
        }
        if let type = headerDetails.type, let powerOutput = headerDetails.powerOutput{
            typeLabel.text = "\(type) \(powerOutput)"
            typeLabel.textColor = ColorManager.primaryTextColor
            typeLabel.font = FontManager.regular()
        }
        
        addressLabel.text = headerDetails.chargerLocation
        addressLabel.textColor = ColorManager.subtitleTextColor
        addressLabel.font = FontManager.regular(size: 14)
        
        chargerIdTitleLabel.text = "Charger ID"
        chargerIdTitleLabel.textColor = ColorManager.placeholderColor
        chargerIdTitleLabel.font = FontManager.regular()
        
        chargeridLabel.text = headerDetails.chargerId
        chargeridLabel.textColor = ColorManager.textColor
        chargeridLabel.font = FontManager.regular()
        
        createdAtLabel.text = headerDetails.createdAt
        createdAtLabel.textColor = ColorManager.textColor
        createdAtLabel.font = FontManager.light(size: 12)
    }
}
