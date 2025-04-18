//
//  GrandTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 17/04/25.
//

import UIKit

class GrandTableViewCell: UITableViewCell {

    static let identifier = "GrandTableViewCell"
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
        setupStackView()
    }
    func configure(total : String) {
        let titleLabel = UILabel()
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.regular()
        titleLabel.text = " Grand Total"
        stackView.addArrangedSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.textColor = ColorManager.textColor
        valueLabel.font = FontManager.bold(size: 20)
        valueLabel.text = total
        stackView.addArrangedSubview(valueLabel)
        
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
        
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
    }
}
