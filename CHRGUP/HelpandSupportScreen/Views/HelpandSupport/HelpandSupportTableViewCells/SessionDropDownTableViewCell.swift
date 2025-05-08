//
//  SessionDropDownTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 30/04/25.
//

import UIKit

class SessionDropDownTableViewCell: UITableViewCell {

    static let identifier = "SessionDropDownTableViewCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var vehicleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(chargingInfo : HistoryModel){
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
        backView.layer.cornerRadius = 8
        backView.clipsToBounds = true
        
        titleLabel.text = chargingInfo.locationName
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.regular()
        
        vehicleLabel.text = chargingInfo.vehicle
        vehicleLabel.textColor = ColorManager.subtitleTextColor
        vehicleLabel.font = FontManager.regular(size: 14)
        
        timeLabel.text = formatDate(chargingInfo.createdAt)
        timeLabel.textColor = ColorManager.subtitleTextColor
        timeLabel.font = FontManager.regular(size: 14)
        
        
    }
    func formatDate(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: isoString) else {
            return isoString // fallback in case of failure
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")

        return displayFormatter.string(from: date)
    }
    
}
