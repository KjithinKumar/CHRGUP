//
//  LoadingTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/09/25.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    static let idenytifier = "LoadingTableViewCell"
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        spinner.startAnimating()
        spinner.color = ColorManager.primaryTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
