//
//  NotificationTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/07/25.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    static let identifier = "NotificationTableViewCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with notification: NotificationModel) {
        configureUI()
        titleLabel.text = notification.title
        titleLabel.font = FontManager.bold(size: 17)
        subtitleLabel.text = notification.description
        subtitleLabel.font = FontManager.regular()
        dateLabel.text = formatDate(notification.updatedAt)
        dateLabel.font = FontManager.regular(size: 14)
    }
    func configureUI(){
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
        backView .layer.cornerRadius = 8
        backView.clipsToBounds = true
    }
    
    func setShimmering(isShimmering: Bool){
        configureUI()
        if isShimmering{
            titleLabel.backgroundColor = .label.withAlphaComponent(0.5)
            titleLabel.layer.cornerRadius = 8
            titleLabel.textColor = .clear
            titleLabel.startShimmering()
            
            subtitleLabel.backgroundColor = .label.withAlphaComponent(0.5)
            subtitleLabel.layer.cornerRadius = 8
            subtitleLabel.textColor = .clear
            subtitleLabel.startShimmering()
            
            dateLabel.backgroundColor = .label.withAlphaComponent(0.5)
            dateLabel.layer.cornerRadius = 8
            dateLabel.textColor = .clear
            dateLabel.startShimmering()
        }else{
            titleLabel.backgroundColor = .clear
            titleLabel.textColor = ColorManager.primaryTextColor
            titleLabel.stopShimmering()
            
            subtitleLabel.backgroundColor = .clear
            subtitleLabel.textColor = ColorManager.textColor
            subtitleLabel.stopShimmering()
            
            dateLabel.backgroundColor = .clear
            dateLabel.textColor = ColorManager.subtitleTextColor
            dateLabel.stopShimmering()
        }
    }
    func formatDate(_ input: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let date = isoFormatter.date(from: input) else {
            print("Failed to parse ISO date: \(input)")
            return input
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        displayFormatter.timeZone = .current

        return displayFormatter.string(from: date)
    }
}
