//
//  HistoryInfoViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/04/25.
//

import UIKit

class HistoryInfoViewController: UIViewController {
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var paymentStatusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bottomview: UIView!
    @IBOutlet weak var titleOneLabel: UILabel!
    @IBOutlet weak var SubtitleOneLabel: UILabel!
    @IBOutlet weak var titleTwoLabel: UILabel!
    @IBOutlet weak var SubtitleTwoLabel: UILabel!
    @IBOutlet weak var titleThreeLabel: UILabel!
    @IBOutlet weak var subtitleThreeLabel: UILabel!
    @IBOutlet weak var titlefourLabel: UILabel!
    @IBOutlet weak var subtitleFourLabel: UILabel!
    @IBOutlet weak var titleFiveLabel: UILabel!
    @IBOutlet weak var subtitleFiveLabel: UILabel!
    @IBOutlet weak var titleSixLabel: UILabel!
    @IBOutlet weak var subtitleSixLabel: UILabel!
    
    var historyInfo : HistoryModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        
        bottomview.backgroundColor = ColorManager.secondaryBackgroundColor
        bottomview.layer.cornerRadius = 10
        
        LocationLabel.text = historyInfo?.locationName
        LocationLabel.textColor = ColorManager.textColor
        LocationLabel.font = FontManager.bold(size: 19)
        
        addressLabel.text = historyInfo?.address
        addressLabel.textColor = ColorManager.subtitleTextColor
        addressLabel.font = FontManager.light()
        
        priceLabel.text = historyInfo?.paymentAmount
        priceLabel.textColor = ColorManager.textColor
        priceLabel.font = FontManager.bold(size: 18)
        
        if historyInfo?.paymentStatus == "captured"{
            statusImageView.image = UIImage(named: "Completed")
            paymentStatusLabel.text = AppStrings.History.completedText
            paymentStatusLabel.textColor = ColorManager.primaryColor
            
        }else{
            statusImageView.image = UIImage(named: "Pending")
            paymentStatusLabel.text = AppStrings.History.failed
            paymentStatusLabel.textColor = ColorManager.pendingColor
        }
        paymentStatusLabel.font = FontManager.regular()
        
        if let chargeStart = historyInfo?.createdAt{
            timeLabel.text = formatDate(chargeStart)
        }
        timeLabel.textColor = ColorManager.textColor
        timeLabel.font = FontManager.regular()
        
        titleOneLabel.text = AppStrings.History.chargerIdText
        titleOneLabel.textColor = ColorManager.subtitleTextColor
        titleOneLabel.font = FontManager.regular()
        
        SubtitleOneLabel.text = historyInfo?.chargerName
        SubtitleOneLabel.textColor = ColorManager.textColor
        SubtitleOneLabel.font = FontManager.regular()
        
        titleTwoLabel.text = AppStrings.History.chargingTypeText
        titleTwoLabel.textColor = ColorManager.subtitleTextColor
        titleTwoLabel.font = FontManager.regular()
        
        let bulletPoint = "• "
        let text = "\(historyInfo?.chargerType ?? "") - \(historyInfo?.powerOutput ?? "")"
        if historyInfo?.chargerType == "DC"{
            let attributedString = NSMutableAttributedString(string: bulletPoint, attributes: [.foregroundColor: ColorManager.dcbulletColor])
            attributedString.append(NSAttributedString(string: text, attributes: [.foregroundColor: ColorManager.textColor]))
            SubtitleTwoLabel.attributedText = attributedString
        }else{
            let attributedString = NSMutableAttributedString(string: bulletPoint, attributes: [.foregroundColor: ColorManager.acbulletColor])
            attributedString.append(NSAttributedString(string: text, attributes: [.foregroundColor: ColorManager.textColor]))
            SubtitleTwoLabel.attributedText = attributedString
        }
        
        titleThreeLabel.text = AppStrings.History.trasactionIdText
        titleThreeLabel.textColor = ColorManager.subtitleTextColor
        titleThreeLabel.font = FontManager.regular()
        
        if let transactionId = historyInfo?.transactionId{
            subtitleThreeLabel.text = transactionId
        }
        subtitleThreeLabel.text = "N/A"
        subtitleThreeLabel.textColor = ColorManager.textColor
        subtitleThreeLabel.font = FontManager.regular()
        
        titlefourLabel.text = AppStrings.History.energyConsumedText
        titlefourLabel.textColor = ColorManager.subtitleTextColor
        titlefourLabel.font = FontManager.regular()
        
        subtitleFourLabel.text = historyInfo?.energyConsumed
        subtitleFourLabel.textColor = ColorManager.textColor
        subtitleFourLabel.font = FontManager.regular()
        
        titleFiveLabel.text = AppStrings.History.chargingTimeText
        titleFiveLabel.textColor = ColorManager.subtitleTextColor
        titleFiveLabel.font = FontManager.regular()
        
        subtitleFiveLabel.text = historyInfo?.chargeTime
        subtitleFiveLabel.textColor = ColorManager.textColor
        subtitleFiveLabel.font = FontManager.regular()
        
        titleSixLabel.text = AppStrings.History.paymentMethodText
        titleSixLabel.textColor = ColorManager.subtitleTextColor
        titleSixLabel.font = FontManager.regular()
        
        subtitleSixLabel.text = historyInfo?.paymentMethod
        subtitleSixLabel.textColor = ColorManager.textColor
        subtitleSixLabel.font = FontManager.regular()
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
