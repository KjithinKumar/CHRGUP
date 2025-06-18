//
//  MessageTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 29/04/25.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    weak var delegate : textFieldsdidChangeDelegate?
    
    static let identifier = "MessageTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(title : String, placeHolder : String, delegate : textFieldsdidChangeDelegate?){
        self.delegate = delegate
        
        titleLabel.text = title
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.regular()
        
       
        messageTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        messageTextView.backgroundColor = ColorManager.secondaryBackgroundColor
        messageTextView.layer.cornerRadius = 8
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = ColorManager.thirdBackgroundColor.cgColor
        messageTextView.textColor = ColorManager.primaryTextColor
        messageTextView.tintColor = ColorManager.primaryColor
        messageTextView.clipsToBounds = true
        
        messageTextView.delegate = self
        
    }
    
}
extension MessageTableViewCell : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textFieldDidChange(in: self, newText: textView.text)
    }
    
}
