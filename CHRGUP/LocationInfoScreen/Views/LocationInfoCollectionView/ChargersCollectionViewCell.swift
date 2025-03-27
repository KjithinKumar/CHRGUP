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
    
    
    static let identifier = "ChargersCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configure(chargerInfo: ChargerInfo){
        firstBackgroundView.layer.cornerRadius = 8
        if chargerInfo.status == "Available"{
            firstBackgroundView.backgroundColor = ColorManager.primaryColor
            statusLabel.textColor = ColorManager.backgroundColor
            statusLabel.text = chargerInfo.status
        }else if chargerInfo.status == "Inactive"{
            firstBackgroundView.backgroundColor = ColorManager.thirdBackgroundColor
            statusLabel.textColor = ColorManager.backgroundColor
            statusLabel.text = chargerInfo.status
        }else{
            firstBackgroundView.backgroundColor = ColorManager.inUseColor
            statusLabel.text = chargerInfo.status
            statusLabel.textColor = ColorManager.backgroundColor
        }
        
        titleLabel.text = chargerInfo.subType
        titleLabel.font = FontManager.bold(size: 14)
        titleLabel.textColor = ColorManager.textColor
        
        if chargerInfo.subType == "CCS2"{
            imageView.image = UIImage(named: "CCS2")
        }else if chargerInfo.subType == "Type6"{
            imageView.image = UIImage(named: "type6")
        }else{
            imageView.image = UIImage(named: "type7")
        }
        imageView.tintColor = ColorManager.textColor
        
        let bulletPoint = "• "
        let text = "\(chargerInfo.type ?? "") \(chargerInfo.powerOutput ?? "")"
        if chargerInfo.type == "DC"{
            let attributedString = NSMutableAttributedString(string: bulletPoint, attributes: [.foregroundColor: ColorManager.dcbulletColor])
            attributedString.append(NSAttributedString(string: text, attributes: [.foregroundColor: ColorManager.textColor]))
            typeLabel.attributedText = attributedString
        }else{
            let attributedString = NSMutableAttributedString(string: bulletPoint, attributes: [.foregroundColor: ColorManager.acbulletColor])
            attributedString.append(NSAttributedString(string: text, attributes: [.foregroundColor: ColorManager.textColor]))
            typeLabel.attributedText = attributedString
        }
        
        priceLabel.text = "Rs \(chargerInfo.costPerUnit?.amount ?? 0) /Unit"
        priceLabel.textColor = ColorManager.textColor

        
        secondBackgroundView.backgroundColor = ColorManager.secondaryBackgroundColor
    }

}
