//
//  ChargersCollectionViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/03/25.
//

import UIKit

class ChargersCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var firstBackgroundView: UIView!
    @IBOutlet weak var secondBackgroundView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var chargerIdLabel: UILabel!
    @IBOutlet weak var connectorIdLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    
    
    static let identifier = "ChargersCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configure(itemsDisplay : ConnectorDisplayItem){
        firstBackgroundView.layer.cornerRadius = 8
        let chargerInfo = itemsDisplay.chargerInfo
        let connector = itemsDisplay.connector
        if connector.status == "Available"{
            firstBackgroundView.backgroundColor = ColorManager.primaryColor
            statusLabel.textColor = ColorManager.buttonTextColor
            statusLabel.text = connector.status
            chargerIdLabel.textColor = ColorManager.primaryTextColor
            connectorIdLabel.textColor = ColorManager.primaryTextColor
            titleLabel.textColor = ColorManager.textColor
            imageView.tintColor = ColorManager.textColor
            typeLabel.textColor = ColorManager.textColor
            priceLabel.textColor = ColorManager.textColor
        }else if connector.status == "Inactive"{
            firstBackgroundView.backgroundColor = ColorManager.thirdBackgroundColor
            statusLabel.textColor = ColorManager.backgroundColor
            statusLabel.text = connector.status
            chargerIdLabel.textColor = ColorManager.placeholderColor
            connectorIdLabel.textColor = ColorManager.placeholderColor
            titleLabel.textColor = ColorManager.placeholderColor
            imageView.tintColor = ColorManager.placeholderColor
            typeLabel.textColor = ColorManager.placeholderColor
            priceLabel.textColor = ColorManager.placeholderColor
        }else{
            firstBackgroundView.backgroundColor = ColorManager.inUseColor
            statusLabel.text = "In Use"
            statusLabel.textColor = ColorManager.buttonTextColor
            chargerIdLabel.textColor = ColorManager.inUseColor
            connectorIdLabel.textColor = ColorManager.inUseColor
            titleLabel.textColor = ColorManager.textColor
            imageView.tintColor = ColorManager.textColor
            typeLabel.textColor = ColorManager.textColor
            priceLabel.textColor = ColorManager.textColor
        }
    
        chargerIdLabel.text = chargerInfo.name
        chargerIdLabel.font = FontManager.regular(size: 14)
    
        connectorIdLabel.text = "Connector ID: \(connector.connectorId)"
        connectorIdLabel.font = FontManager.regular(size: 14)
        
        titleLabel.text = chargerInfo.subType
        titleLabel.font = FontManager.regular(size: 12)
        
        
        if chargerInfo.subType == "CCS2"{
            imageView.image = UIImage(systemName: "ev.plug.dc.ccs2")
        }else if chargerInfo.subType == "Type6"{
            imageView.image = UIImage(named: "type6")
        }else{
            imageView.image = UIImage(systemName: "ev.plug.ac.type.2")
        }
        
        
        let text = "\(chargerInfo.type ?? "") \(chargerInfo.powerOutput ?? "")"
        typeLabel.text = text
        if chargerInfo.type == "DC"{
            typeImageView.image = UIImage(named: "dc")
        }else{
            typeImageView.image = UIImage(named: "ac")
        }
        typeLabel.font = FontManager.regular(size: 12)
        priceLabel.text = "Rs \(chargerInfo.costPerUnit?.amount ?? 0) /Unit"
        priceLabel.font = FontManager.regular(size: 12)
        
        secondBackgroundView.backgroundColor = ColorManager.secondaryBackgroundColor
    }
    func setSelected(_ selected: Bool) {
        if selected {
            firstBackgroundView.backgroundColor = ColorManager.primaryColor
            chargerIdLabel.textColor = ColorManager.primaryTextColor
            connectorIdLabel.textColor = ColorManager.primaryTextColor
        } else {
            firstBackgroundView.backgroundColor = ColorManager.primaryColor.withAlphaComponent(0.5)
            chargerIdLabel.textColor = ColorManager.primaryTextColor.withAlphaComponent(0.5)
            connectorIdLabel.textColor = ColorManager.primaryTextColor.withAlphaComponent(0.5)
        }
    }

}
