//
//  ChatTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 05/05/25.
//

import UIKit
import SDWebImage

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var leftMessageView: UIView!
    @IBOutlet weak var rightMessageView: UIView!
    @IBOutlet weak var leftMessageLabel: UILabel!
    @IBOutlet weak var rightMessageLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet weak var screenshotImageView: UIImageView!
    
    static let identifier = "ChatTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        screenshotImageView.image = nil
        screenshotImageView.isHidden = true
        leftMessageLabel.text = ""
        rightMessageLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(message : MessageModel){
        spacerView.backgroundColor = .clear
        screenshotImageView.isHidden = true
        screenshotImageView.translatesAutoresizingMaskIntoConstraints = false
        if message.senderModel == "User"{
            leftMessageView.isHidden = true
            rightMessageView.isHidden = false
            
            rightMessageLabel.textColor = ColorManager.textColor
            rightMessageLabel.font = FontManager.regular()
            let messageText = cleanMessageText(from: message.message)
            rightMessageLabel.text = messageText
            
            if let imageUrl = self.extractImageURL(from: message.message){
                screenshotImageView.sd_setImage(with: imageUrl,placeholderImage: UIImage(systemName: "photo.fill"))
                screenshotImageView.tintColor = ColorManager.backgroundColor
                screenshotImageView.isHidden = false
                screenshotImageView.layer.cornerRadius = 10
                screenshotImageView.clipsToBounds = true
                screenshotImageView.contentMode = .scaleAspectFit
                screenshotImageView.heightAnchor.constraint(equalToConstant: 225).isActive = true
                screenshotImageView.widthAnchor.constraint(equalToConstant: 175).isActive = true
            }else{
                screenshotImageView.isHidden = true
            }
            
            rightMessageView.layer.cornerRadius = 20
            rightMessageView.layer.maskedCorners = [.layerMinXMinYCorner,
                                            .layerMaxXMinYCorner,
                                            .layerMinXMaxYCorner]
            rightMessageView.layer.masksToBounds = true
            rightMessageView.backgroundColor = ColorManager.thirdBackgroundColor
            
            rightTimeLabel.text = convertToTimeOnly(message.createdAt)
            rightTimeLabel.textColor = ColorManager.subtitleTextColor
            rightTimeLabel.font = FontManager.light(size: 9)
            
        }else{
            leftMessageView.isHidden = false
            rightMessageView.isHidden = true
            leftMessageLabel.text = message.message
            leftMessageLabel.textColor = ColorManager.textColor
            leftMessageLabel.font = FontManager.regular()
            
            leftMessageView.layer.cornerRadius = 20
            leftMessageView.layer.maskedCorners = [.layerMinXMaxYCorner,
                                            .layerMaxXMinYCorner,
                                            .layerMaxXMaxYCorner]
            leftMessageView.layer.masksToBounds = true
            leftMessageView.backgroundColor = ColorManager.secondaryBackgroundColor
            
            leftTimeLabel.text = convertToTimeOnly(message.createdAt)
            leftTimeLabel.textColor = ColorManager.subtitleTextColor
            leftTimeLabel.font = FontManager.light(size: 9)
        }
    }
  
    func convertToTimeOnly(_ isoDate: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        displayFormatter.timeZone = TimeZone.current
        
        if let date = isoFormatter.date(from: isoDate) {
            return displayFormatter.string(from: date)
        }
        return nil
    }
    func extractImageURL(from message: String) -> URL? {
        let components = message.components(separatedBy: "\n")
        for line in components {
            if line.starts(with: "Screenshot:") {
                let urlString = line.replacingOccurrences(of: "Screenshot: ", with: "").trimmingCharacters(in: .whitespaces)
                return URL(string: urlString)
            }
        }
        return nil
    }
    func cleanMessageText(from message: String) -> String {
        let lines = message.components(separatedBy: "\n")
        let filteredLines = lines.filter { !$0.starts(with: "Screenshot:") }
        return filteredLines.joined(separator: "\n")
    }
}
