//
//  FavouriteDockTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 27/03/25.
//

import UIKit
protocol FavouriteDockTableViewCellDelegate: AnyObject {
    func didSelectedFavouriteButton(at indexPath: IndexPath)
}

class FavouriteDockTableViewCell: UITableViewCell {

    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    static let identifier = "FavouriteDockTableViewCell"
    var indexPath: IndexPath?
    weak var delegate: FavouriteDockTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUi()
 
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        backView.updateShimmerLayout()
        titleLabel.updateShimmerLayout()
        addressLabel.updateShimmerLayout()
        pointsLabel.updateShimmerLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func configure(chargerLocation : ChargerLocation, indexPath : IndexPath,delegate : FavouriteDockTableViewCellDelegate){
        self.indexPath = indexPath
        self.delegate = delegate
        let favourites = UserDefaultManager.shared.getFavouriteLocations()
        if favourites.contains(where: { $0 ==  chargerLocation.id}){
            setUpButton(favourite: true)
        }else{
            setUpButton(favourite: false)
        }
        titleLabel.text = chargerLocation.locationName
        addressLabel.text = chargerLocation.address
        
        
        let chargersStatus = chargerLocation.chargerInfo.map { $0.status }
        var pointsAvailableCount = 0
        for status in chargersStatus {
            if status == "Available" {
                pointsAvailableCount += 1
            }
        }
        pointsLabel.text = "\(pointsAvailableCount) points available"
        
        if pointsAvailableCount > 0 {
            pointsLabel.textColor = ColorManager.primaryColor
        }else{
            pointsLabel.textColor = ColorManager.thirdBackgroundColor
        }
    }
    func setShimmering(isShimmering : Bool){
        if isShimmering{
            
            titleLabel.backgroundColor = .white
            titleLabel.textColor = .white
            titleLabel.startShimmering()
            titleLabel.layer.cornerRadius = 8
            
            addressLabel.startShimmering()
            addressLabel.textColor = .white
            addressLabel.backgroundColor = .white
            addressLabel.layer.cornerRadius = 8
            
            pointsLabel.layer.cornerRadius = 8
            pointsLabel.startShimmering()
            pointsLabel.textColor = .white
            pointsLabel.backgroundColor = .white
            
            backView.startShimmering()
            backView.backgroundColor = .gray.withAlphaComponent(0.5)
            
            favouriteButton.startShimmering()
            
        }else{
            configureUi()
            titleLabel.stopShimmering()
            titleLabel.backgroundColor = .clear
            
            addressLabel.stopShimmering()
            addressLabel.backgroundColor = .clear
            
            pointsLabel.stopShimmering()
            pointsLabel.backgroundColor = .clear
            
            backView.backgroundColor = ColorManager.secondaryBackgroundColor
            backView.stopShimmering()
            
            favouriteButton.stopShimmering()
        }
    }
    func configureUi(){
        favouriteButton.tintColor = ColorManager.textColor
        
        backView.backgroundColor = ColorManager.secondaryBackgroundColor
        backView.layer.cornerRadius = 8
        
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.bold(size: 20)
        
        addressLabel.textColor = ColorManager.textColor
        addressLabel.font = FontManager.light()
        
        pointsLabel.font = FontManager.light()
        
        contentView.backgroundColor = ColorManager.backgroundColor
        
    }
    func setUpButton(favourite: Bool){
        if favourite{
            favouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            favouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    @IBAction func favouriteButtonPressed(_ sender: Any) {
        if let indexPath = indexPath{
            setUpButton(favourite: false)
            self.delegate?.didSelectedFavouriteButton(at: indexPath)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
