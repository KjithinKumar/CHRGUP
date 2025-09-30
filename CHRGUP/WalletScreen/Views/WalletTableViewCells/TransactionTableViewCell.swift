//
//  TransactionTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/09/25.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    static let identifier = "TransactionTableViewCell"
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var refundButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(with transaction : transactionModel){
        backView.layer.cornerRadius = 8
        backView.clipsToBounds = true
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
        
        if transaction.type.contains("credit"){
            statusView.backgroundColor = ColorManager.primaryTextColor
            amountLabel.textColor = ColorManager.primaryTextColor
            amountLabel.text = "+ ₹\(transaction.amount / 100)"
        }else if transaction.type.contains("debit"){
            statusView.backgroundColor = ColorManager.cancelledColor
            amountLabel.textColor = ColorManager.cancelledColor
            amountLabel.text = "- ₹\(transaction.amount / 100)"
        }else {
            statusView.backgroundColor = ColorManager.reservedColor
            amountLabel.textColor = ColorManager.reservedColor
            amountLabel.text = "- ₹\(transaction.amount / 100)"
        }
        
        amountLabel.font = FontManager.bold(size: 17)
        
        titleLabel.text = transaction.description
        titleLabel.textColor = ColorManager.subtitleTextColor
        
        titleLabel.font = FontManager.regular(size: 14)
        
        dateLabel.text = formatDate(transaction.timestamp)
        dateLabel.textColor = ColorManager.subtitleTextColor
        dateLabel.font = FontManager.regular(size: 14)
        
        transactionIdLabel.text = transaction.transactionId
        transactionIdLabel.textColor = ColorManager.subtitleTextColor
        transactionIdLabel.font = FontManager.regular()
        
        refundButton.setTitleColor(ColorManager.textColor, for: .normal)
        //refundButton.isHidden = !transaction.isRefund
        refundButton.isHidden = true
    }
    func formatDate(_ input: String) -> String {
        let parser = DateFormatter()
        parser.dateFormat = "d/M/yyyy, h:mm:ss a"
        parser.locale = Locale(identifier: "en_US_POSIX")

        guard let date = parser.date(from: input) else {
            return input // fallback
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")

        return displayFormatter.string(from: date)
    }
    @IBAction func refundButtonPressed(_ sender: Any) {
    }
    
}
