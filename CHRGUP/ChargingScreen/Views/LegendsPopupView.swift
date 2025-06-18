//
//  LegendsPopupView.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/04/25.
//


import UIKit
import Foundation

struct LegendItem {
    let iconName: String
    let title: String
    let shouldAnimate: Bool
}
class LegendsPopupView: UIView {
    
    private let itemsLeft: [LegendItem]
    private let itemsRight: [LegendItem]

    init(leftItems: [LegendItem], rightItems: [LegendItem]) {
        self.itemsLeft = leftItems
        self.itemsRight = rightItems
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = ColorManager.secondaryBackgroundColor
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner,
                               .layerMaxXMaxYCorner,
                               .layerMinXMaxYCorner]
        translatesAutoresizingMaskIntoConstraints = false

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Legends"
        titleLabel.font = FontManager.bold(size: 18)
        titleLabel.textColor = ColorManager.textColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Two vertical stacks
        let leftStack = verticalStack(from: itemsLeft)
        let rightStack = verticalStack(from: itemsRight)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .black
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dividerView)

        NSLayoutConstraint.activate([
            dividerView.centerXAnchor.constraint(equalTo: self.centerXAnchor,constant: -15),
            dividerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 45),
            dividerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            dividerView.widthAnchor.constraint(equalToConstant: 1)
        ])


        // Horizontal stack
        let columnsStack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        columnsStack.axis = .horizontal
        columnsStack.spacing = 5
        columnsStack.alignment = .top
        columnsStack.distribution = .fill
        columnsStack.translatesAutoresizingMaskIntoConstraints = false
        
        

        // Main vertical stack
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, columnsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }

    private func verticalStack(from items: [LegendItem]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12

        for item in items {
            let row = legendRow(for: item)
            stack.addArrangedSubview(row)
        }

        return stack
    }

    private func legendRow(for item: LegendItem) -> UIView {
        let icon = UIImageView(image: UIImage(named: item.iconName))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true

        if item.shouldAnimate {
            animate(icon)
        }

        let label = UILabel()
        label.text = item.title
        label.textColor = ColorManager.subtitleTextColor
        label.font = FontManager.light()

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.spacing = 5

        return row
    }

    private func animate(_ imageView: UIImageView) {
        imageView.alpha = 0.2
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse], animations: {
            imageView.alpha = 1.5
        })
    }
}
