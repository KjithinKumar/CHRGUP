//
//  TariffTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/03/25.
//

import UIKit

class TariffTableViewCell: UITableViewCell {
    
    static let identifier = "TariffTableViewCell"
    @IBOutlet weak var chargingTitleLabel: UILabel!
    @IBOutlet weak var parkingTItleLabel: UILabel!
    @IBOutlet weak var chargingLabel: UILabel!
    @IBOutlet weak var parkingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(charging: Bool, parking : Bool){
        chargingTitleLabel.text = AppStrings.ChargerInfo.chargingTariffText
        chargingTitleLabel.font = FontManager.bold(size: 17)
        chargingTitleLabel.textColor = ColorManager.placeholderColor
        
        chargingLabel.text = charging ? "FREE" : "PAID"
        chargingLabel.textColor = ColorManager.textColor
        chargingLabel.font = FontManager.bold(size: 17)
        
        parkingTItleLabel.text = AppStrings.ChargerInfo.parkingTariffText
        parkingTItleLabel.font = FontManager.bold(size: 17)
        parkingTItleLabel.textColor = ColorManager.placeholderColor
    
        parkingLabel.text = parking ? "FREE" : "PAID"
        parkingLabel.textColor = ColorManager.textColor
        parkingLabel.font = FontManager.bold(size: 17)
        
    }
    
}
