//
//  LocationImageCollectionViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/03/25.
//

import UIKit
import SDWebImage

class LocationImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var locationImageView: UIImageView!
    
    static let identifier: String = "LocationImageCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure(with image: String) {
        let urlString = URLs.baseUrls3+image
        let url = URL(string: urlString)
        locationImageView.sd_setImage(with: url)
    }

}
