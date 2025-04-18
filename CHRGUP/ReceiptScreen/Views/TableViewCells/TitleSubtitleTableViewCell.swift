//
//  TitleSubtitleTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 17/04/25.
//

import UIKit

class TitleSubtitleTableViewCell: UITableViewCell {

    static let identifier = "TitleSubtitleTableViewCell"
    private let stackView = UIStackView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setupStackView()
    }
    func configure(details : [[String : String]]){
        addKeyValuePairsToStackView(data: details)
        
    }
    private func setupStackView() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
    }
    private func addKeyValuePairsToStackView(data: [[String: String]]) {
        for dict in data {
            guard let key = dict.keys.first, let value = dict.values.first else { continue }
            
            let container = UIStackView()
            container.axis = .horizontal
            container.distribution = .equalSpacing
            
            let keyLabel = UILabel()
            keyLabel.text = key
            keyLabel.font = FontManager.regular()
            keyLabel.textColor = ColorManager.subtitleTextColor
            
            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = FontManager.regular()
            valueLabel.textColor = ColorManager.textColor
            if valueLabel.text == "FREE" || valueLabel.text == "₹ 0.00"{
                valueLabel.textColor = ColorManager.primaryColor
            }
            valueLabel.textAlignment = .right
            
            container.addArrangedSubview(keyLabel)
            container.addArrangedSubview(valueLabel)
            
            stackView.addArrangedSubview(container)
        }
    }
}
