//
//  TrackTicketTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 01/05/25.
//

import UIKit

class TrackTicketTableViewCell: UITableViewCell {
    
    static let identifier = "TrackTicketTableViewCell"
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var createLabel: UILabel!
    @IBOutlet weak var ticketNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        createLabel.updateShimmerLayout()
        titleLabel.updateShimmerLayout()
        statusLabel.updateShimmerLayout()
        categoryLabel.updateShimmerLayout()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(ticket : TicketModel){
        createLabel.text = convertDateString(ticket.createdAt)
        
        if ticket.status == "In Progress"{
            statusLabel.textColor = ColorManager.primaryColor
        }
        statusLabel.text = ticket.status
        
        titleLabel.text = ticket.title
        
        categoryLabel.text = ticket.category
    }
    func setShimmering(isShimmering : Bool){
        if isShimmering{
            backView.backgroundColor = ColorManager.secondaryBackgroundColor
            backView.layer.cornerRadius = 8
            backView.layer.masksToBounds = true
            createLabel.textColor = .white
            createLabel.startShimmering()
            createLabel.layer.cornerRadius = 8
            createLabel.backgroundColor = .white
            ticketNumberLabel.textColor = .clear
            titleLabel.textColor = .white
            titleLabel.layer.cornerRadius = 8
            titleLabel.backgroundColor = .white
            titleLabel.startShimmering()
            statusLabel.textColor = .white
            statusLabel.startShimmering()
            statusLabel.layer.cornerRadius = 8
            statusLabel.backgroundColor = .white
            categoryLabel.textColor = .white
            categoryLabel.backgroundColor = .white
            categoryLabel.startShimmering()
            categoryLabel.layer.cornerRadius = 8
        }else{
            createLabel.stopShimmering()
            createLabel.backgroundColor = .clear
            titleLabel.stopShimmering()
            titleLabel.backgroundColor = .clear
            statusLabel.stopShimmering()
            statusLabel.backgroundColor = .clear
            categoryLabel.stopShimmering()
            categoryLabel.backgroundColor = .clear
            configureUI()
        }
    }
    func configureUI(){
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
        
        createLabel.textColor = ColorManager.subtitleTextColor
        createLabel.font = FontManager.regular(size: 14)
        
        statusLabel.textColor = ColorManager.subtitleTextColor
        statusLabel.font = FontManager.regular(size: 14)
        
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.bold(size: 17)
        
        categoryLabel.textColor = ColorManager.subtitleTextColor
        categoryLabel.font = FontManager.regular(size: 14)
        
    }
    func convertDateString(_ isoDate: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd/MM/yy"
        displayFormatter.timeZone = TimeZone.current

        if let date = isoFormatter.date(from: isoDate) {
            return displayFormatter.string(from: date)
        } else {
            return nil
        }
    }
}
