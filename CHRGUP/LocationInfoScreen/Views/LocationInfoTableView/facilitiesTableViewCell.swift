//
//  facilitiesTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/03/25.
//

import UIKit

class facilitiesTableViewCell: UITableViewCell {
    
    var facilities : [Facility]?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    static let identifier = "facilitiesTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(facilities : [Facility]){
        self.facilities = facilities
        titleLabel.text = AppStrings.ChargerInfo.facilityText
        titleLabel.textColor = ColorManager.placeholderColor
        titleLabel.font = FontManager.bold(size: 17)
        
        collectionView.backgroundColor = .clear

    }
    
}
extension facilitiesTableViewCell : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func configureCollectionView(){
        collectionView.register(UINib(nibName: "facilityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: facilityCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.heightAnchor.constraint(equalToConstant: 85).isActive = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.sectionInset = .zero
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return facilities?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: facilityCollectionViewCell.identifier, for: indexPath) as? facilityCollectionViewCell
        if let facility = facilities?[indexPath.row]{
            cell?.configure(facility: facility)
        }
        return cell ?? UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 55, height: 85)
    }
}


