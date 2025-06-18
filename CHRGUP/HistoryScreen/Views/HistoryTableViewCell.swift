//
//  HistoryTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/04/25.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var backView: UIView!
    
    static let identifier = "HistoryTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        locationLabel.updateShimmerLayout()
        vehicleLabel.updateShimmerLayout()
        timeLabel.updateShimmerLayout()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func configure(chargingInfo : HistoryModel){
        locationLabel.text = chargingInfo.locationName
        locationLabel.textColor = ColorManager.textColor
        locationLabel.font = FontManager.bold(size: 17)
        
        vehicleLabel.text = chargingInfo.vehicle
        if chargingInfo.vehicle == "undefined undefined undefined"{
            vehicleLabel.text = "Vehicle not found"
        }
        vehicleLabel.textColor = ColorManager.subtitleTextColor
        vehicleLabel.font = FontManager.regular(size: 14)
        
        timeLabel.text = formatDate(chargingInfo.createdAt)
        timeLabel.textColor = ColorManager.subtitleTextColor
        timeLabel.font = FontManager.regular(size: 14)
        
        if chargingInfo.chargerType == "AC"{
            typeView.backgroundColor = ColorManager.acbulletColor
        }else{
            typeView.backgroundColor = ColorManager.dcbulletColor
        }
    }
    func setShimmer(isShimmering : Bool){
        if isShimmering{
            locationLabel.textColor = .clear
            locationLabel.backgroundColor = .label.withAlphaComponent(0.5)
            locationLabel.layer.cornerRadius = 8
            vehicleLabel.textColor = .clear
            vehicleLabel.backgroundColor = .label.withAlphaComponent(0.5)
            vehicleLabel.layer.cornerRadius = 8
            timeLabel.textColor = .clear
            timeLabel.backgroundColor = .label.withAlphaComponent(0.5)
            timeLabel.layer.cornerRadius = 8
            locationLabel.startShimmering()
            vehicleLabel.startShimmering()
            timeLabel.startShimmering()
            configureUI()
        }else{
            locationLabel.stopShimmering()
            locationLabel.textColor = ColorManager.textColor
            locationLabel.backgroundColor = .clear
            vehicleLabel.stopShimmering()
            vehicleLabel.textColor = ColorManager.subtitleTextColor
            vehicleLabel.backgroundColor = .clear
            timeLabel.stopShimmering()
            timeLabel.textColor = ColorManager.subtitleTextColor
            timeLabel.backgroundColor = .clear
            configureUI()
        }
    }
    func configureUI(){
        backView.layer.cornerRadius = 8
        backView.clipsToBounds = true
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
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
