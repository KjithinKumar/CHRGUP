//
//  ChargersTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/03/25.
//

import UIKit
protocol ChargersTableViewCellDelegate : AnyObject {
    func didSelectRaiseTicket()
}

class ChargersTableViewCell: UITableViewCell {

    @IBOutlet weak var raiseTicketButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pointsStackView: UIStackView!
    @IBOutlet weak var pointsImageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var chargersInfo : [ChargerInfo]?
    weak var delegate : ChargersTableViewCellDelegate?
    
    static let identifier: String = "ChargersTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(chargerInfo: [ChargerInfo], pointsAvailable : String, delegate : ChargersTableViewCellDelegate){
        self.delegate = delegate
        self.chargersInfo = chargerInfo
        titleLabel.text = AppStrings.ChargerInfo.ChargersTitle
        titleLabel.textColor = ColorManager.placeholderColor
        titleLabel.font = FontManager.bold(size: 17)
        
        if pointsAvailable == "0"{
            pointsLabel.textColor = ColorManager.thirdBackgroundColor
        }else{
            pointsLabel.textColor = ColorManager.primaryColor
        }
        pointsLabel.text = pointsAvailable + " points available"
        pointsLabel.font = FontManager.light()
        
        let callUsRange = (AppStrings.ChargerInfo.issueText as NSString).range(of: "Raise a ticket")
        let attributedString = NSMutableAttributedString(
            string: AppStrings.ChargerInfo.issueText,
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue,]
        )
        attributedString.addAttribute(.foregroundColor, value: ColorManager.primaryColor, range: callUsRange)
        raiseTicketButton.setAttributedTitle(attributedString, for: .normal)
        raiseTicketButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
        raiseTicketButton.titleLabel?.font = FontManager.light()
        raiseTicketButton.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.reloadData()
        
    }
    @IBAction func raiseTicketButtonPressed(_ sender: Any) {
        delegate?.didSelectRaiseTicket()
    }
}

extension ChargersTableViewCell : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func configureCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ChargersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ChargersCollectionViewCell.identifier)
        collectionView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = .zero
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chargersInfo?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChargersCollectionViewCell.identifier, for: indexPath) as? ChargersCollectionViewCell
        if let chargerInfo = chargersInfo?[indexPath.row]{
            cell?.configure(chargerInfo: chargerInfo)
        }
        return cell ?? ChargersCollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 110, height: 170)
    }
}
