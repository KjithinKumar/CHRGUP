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
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    static let identifier: String = "LocationImageCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSpinner()
    }
    func configure(with image: String) {
        let urlString = URLs.baseUrls3+image
        let url = URL(string: urlString)
        locationImageView.sd_setImage(with: url) { [weak self] _, _, _, _ in
            guard let self else { return }
            self.spinner.stopAnimating()
        }
    }
    private func setupSpinner() {
        spinner.hidesWhenStopped = true
        spinner.color = ColorManager.primaryColor
        spinner.translatesAutoresizingMaskIntoConstraints = false
        locationImageView.addSubview(spinner)
        spinner.startAnimating()
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: locationImageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor)
        ])
    }
}
