//
//  EnergyTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 17/04/25.
//

import UIKit

class EnergyTableViewCell: UITableViewCell {
    
    static let identfiier = "EnergyTableViewCell"
    let stackView = UIStackView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setUpStackView()
    }
    func configure(energy: energyDetailsModel) {
        setUpDataInStackView(data: energy)
        
    }
    func setUpStackView() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
    }
    func setUpDataInStackView(data : energyDetailsModel) {
        guard let titles = data.first,let values = data.last else {return}
        let titlestackView = UIStackView()
        titlestackView.axis = .horizontal
        titlestackView.spacing = 5
        titlestackView.alignment = .center
        titlestackView.distribution = .fillEqually
        titlestackView.backgroundColor = ColorManager.backgroundColor
        titlestackView.layer.cornerRadius = 5
        titlestackView.layer.masksToBounds = true
        for title in titles{
            let container = UIView()
            let titleLabel = UILabel()
            
            titleLabel.text = title
            titleLabel.font = FontManager.regular()
            titleLabel.textColor = ColorManager.subtitleTextColor
            titleLabel.textAlignment = .center
            container.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
                titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
            ])
            
            container.backgroundColor = ColorManager.backgroundColor
            container.layer.cornerRadius = 4
            container.clipsToBounds = true
            
            titlestackView.addArrangedSubview(container)
        }
        let valueStackView = UIStackView()
        valueStackView.axis = .horizontal
        valueStackView.spacing = 5
        valueStackView.alignment = .center
        valueStackView.distribution = .fillEqually
        for value in values{
            let valueLabel = UILabel()
            valueLabel.textColor = ColorManager.textColor
            valueLabel.text = value
            valueLabel.font = FontManager.regular(size: 14)
            valueLabel.adjustsFontSizeToFitWidth = true
            valueLabel.textAlignment = .center
            valueStackView.addArrangedSubview(valueLabel)
        }
        stackView.addArrangedSubview(titlestackView)
        stackView.addArrangedSubview(valueStackView)
    }
}
