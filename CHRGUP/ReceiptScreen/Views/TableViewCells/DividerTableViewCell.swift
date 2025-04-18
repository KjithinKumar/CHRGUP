//
//  DividerTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 17/04/25.
//

import UIKit

class DividerTableViewCell: UITableViewCell {
    
    static let identifier = "DividerTableViewCell"
    private let lineView = UIView()
    private let dottedLine = DottedLineView()
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        lineView.isHidden = true
        dottedLine.isHidden = true
    }
    func setUpLineView(){
        contentView.addSubview(lineView)
        lineView.backgroundColor = ColorManager.subtitleTextColor.withAlphaComponent(0.5)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            lineView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    func setUpdottedLine(){
        contentView.addSubview(dottedLine)
        dottedLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dottedLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dottedLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dottedLine.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            dottedLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            dottedLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setUpLineView()
        setUpdottedLine()
    }
    func configure(style : Divider){
        if style == .solid {
            lineView.isHidden = false
            dottedLine.isHidden = true
        } else {
            dottedLine.isHidden = false
            lineView.isHidden = true
        }
    }

}
class DottedLineView: UIView {

    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawDottedLine()
    }

    private func setupLayer() {
        shapeLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [4, 4] // Dotted: 4 points dash, 4 points space
        layer.addSublayer(shapeLayer)
    }

    private func drawDottedLine() {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        shapeLayer.path = path.cgPath
        shapeLayer.frame = bounds
    }
}
