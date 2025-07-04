//
//  NearByChargerTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 19/03/25.
//

import UIKit

protocol NearByChargerTableViewCellDelegate: AnyObject {
    func addedTofavouriteResponse(response : FavouriteResponseModel?, error : Error?)
}

class NearByChargerTableViewCell: UITableViewCell {

    static let identifier = "NearByChargerTableViewCell"
    @IBOutlet weak var cellbackgroundView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var pointsStackView: UIStackView!
    @IBOutlet weak var pointsImage: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addtoFavStackView: UIStackView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addToFavouriteButton: UIButton!
    @IBOutlet weak var nearByStackView: UIStackView!
    @IBOutlet weak var nearByOneLabel: UILabel!
    @IBOutlet weak var nearByTwoLabel: UILabel!
    @IBOutlet weak var nearByThreeLabel: UILabel!
    @IBOutlet weak var ChargingTypeStackView: UIStackView!
    @IBOutlet weak var chargingTypeImageView: UIImageView!
    @IBOutlet weak var chargingTypeLabel: UILabel!
    @IBOutlet weak var parkingTypeStackView: UIStackView!
    @IBOutlet weak var parkingTypeImageView: UIImageView!
    @IBOutlet weak var parkingTypeLabel: UILabel!
    
    var viewModel : NearByChargerCellViewModel?
    weak var delegate : NearByChargerTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        cellbackgroundView.updateShimmerLayout()
        locationLabel.updateShimmerLayout()
        distanceLabel.updateShimmerLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(viewModel : NearByChargerCellViewModel, delegate : NearByChargerTableViewCellDelegate?){
        self.viewModel = viewModel
        self.delegate = delegate
        configureUi()
        locationLabel.text = viewModel.locationName
        
        parkingTypeLabel.text = viewModel.parkingTypeText
        parkingTypeLabel.textColor = viewModel.parkingTypeColor
        
        chargingTypeLabel.text = viewModel.chargingTypeText
        chargingTypeLabel.textColor = viewModel.chargingTypeColor
        
        if viewModel.chargerLocationAvailable{
            statusLabel.text = "OPEN"
            statusLabel.textColor = ColorManager.primaryTextColor
        }else{
            statusLabel.text = "CLOSED"
            statusLabel.textColor = .red
        }
        
        
        
        distanceLabel.text = viewModel.distance + " Kms"
        distanceLabel.font = FontManager.bold(size: 14)
        
        let facilities = viewModel.facilities
        nearByOneLabel.isHidden = true
        nearByTwoLabel.isHidden = true
        nearByThreeLabel.isHidden = true
        // Now assign based on count
        if facilities.indices.contains(0) {
            nearByOneLabel.isHidden = false
            nearByOneLabel.text = facilities[0]
        }
        if facilities.indices.contains(1) {
            nearByTwoLabel.isHidden = false
            nearByTwoLabel.text = facilities[1]
        }
        if facilities.indices.contains(2) {
            nearByThreeLabel.isHidden = false
            nearByThreeLabel.text = facilities[2]
        }
        
        let pointsAvailable = viewModel.pointsAvailable
        if pointsAvailable == 0{
            pointsLabel.text = "0 Points Available"
            pointsLabel.textColor = ColorManager.thirdBackgroundColor
        }else{
            pointsLabel.text = "\(pointsAvailable) Points Available"
            pointsLabel.textColor = ColorManager.primaryTextColor
        }
    }
    func setShimmer(isShimmering : Bool){
        if isShimmering{
            configureUi()
            cellbackgroundView.startShimmering()
            cellbackgroundView.backgroundColor = ColorManager.secondaryBackgroundColor
            
            locationLabel.backgroundColor = .label.withAlphaComponent(0.5)
            locationLabel.textColor = .clear
            locationLabel.startShimmering()
            locationLabel.layer.cornerRadius = 5
            
            pointsLabel.backgroundColor = .label.withAlphaComponent(0.5)
            pointsLabel.textColor = .clear
            pointsLabel.startShimmering()
            pointsLabel.layer.cornerRadius = 5
            
            statusLabel.backgroundColor = .label.withAlphaComponent(0.5)
            statusLabel.textColor = .clear
            statusLabel.startShimmering()
            statusLabel.layer.cornerRadius = 5
            
            nearByOneLabel.backgroundColor = .label.withAlphaComponent(0.5)
            nearByOneLabel.textColor = .clear
            nearByTwoLabel.backgroundColor = .label.withAlphaComponent(0.5)
            nearByTwoLabel.textColor = .clear
            nearByThreeLabel.backgroundColor = .label.withAlphaComponent(0.5)
            nearByThreeLabel.textColor = .clear
            
            addToFavouriteButton.backgroundColor = .label.withAlphaComponent(0.5)
            addToFavouriteButton.imageView?.tintColor = .label
            addToFavouriteButton.setTitleColor(.clear, for: .normal)
            addToFavouriteButton.startShimmering()
            addToFavouriteButton.layer.cornerRadius = 5
            
            parkingTypeLabel.backgroundColor = .label.withAlphaComponent(0.5)
            parkingTypeLabel.startShimmering()
            parkingTypeLabel.layer.cornerRadius = 5
            parkingTypeLabel.textColor = .clear
            
            chargingTypeLabel.backgroundColor = .label.withAlphaComponent(0.5)
            chargingTypeLabel.startShimmering()
            chargingTypeLabel.layer.cornerRadius = 5
            chargingTypeLabel.textColor = .clear
            
            distanceLabel.backgroundColor = .label.withAlphaComponent(0.5)
            distanceLabel.textColor = .clear
            distanceLabel.startShimmering()
            distanceLabel.layer.cornerRadius = 5
            
            
            navigateButton.startShimmering()
            
            pointsImage.startShimmering()
            
            parkingTypeImageView.startShimmering()
            
            chargingTypeImageView.startShimmering()
            
            
        }else{
            configureUi()
            
            cellbackgroundView.stopShimmering()
            
            locationLabel.stopShimmering()
            locationLabel.backgroundColor = .clear
            
            pointsLabel.stopShimmering()
            pointsLabel.backgroundColor = .clear
            
            statusLabel.stopShimmering()
            statusLabel.backgroundColor = .clear
            
            addToFavouriteButton.backgroundColor = .clear
            addToFavouriteButton.stopShimmering()
            
            parkingTypeLabel.backgroundColor = .clear
            parkingTypeLabel.stopShimmering()
            
            chargingTypeLabel.backgroundColor = .clear
            chargingTypeLabel.stopShimmering()
            
            distanceLabel.stopShimmering()
            distanceLabel.backgroundColor = .clear
            
            
            navigateButton.stopShimmering()
            
            pointsImage.stopShimmering()
            
            parkingTypeImageView.stopShimmering()
            
            chargingTypeImageView.stopShimmering()
        }
    }
    func configureUi(){
        cellbackgroundView.layer.cornerRadius = 8
        cellbackgroundView.backgroundColor = ColorManager.secondaryBackgroundColor
        
        locationLabel.font = FontManager.bold(size: 20)
        locationLabel.textColor = ColorManager.textColor
        
        pointsLabel.textColor = ColorManager.primaryTextColor
        pointsLabel.font = FontManager.light()
        
        statusLabel.textColor = ColorManager.primaryTextColor
        statusLabel.font = FontManager.light()
        
        nearByOneLabel.backgroundColor = ColorManager.thirdBackgroundColor
        nearByOneLabel.layer.cornerRadius = 4
        nearByOneLabel.font = FontManager.light()
        nearByOneLabel.textColor = ColorManager.subtitleTextColor
        nearByOneLabel.layer.masksToBounds = true
        
        
        nearByTwoLabel.backgroundColor = ColorManager.thirdBackgroundColor
        nearByTwoLabel.layer.cornerRadius = 4
        nearByTwoLabel.font = FontManager.light()
        nearByTwoLabel.textColor = ColorManager.subtitleTextColor
        nearByTwoLabel.layer.masksToBounds = true
        
        nearByThreeLabel.backgroundColor = ColorManager.thirdBackgroundColor
        nearByThreeLabel.layer.cornerRadius = 4
        nearByThreeLabel.font = FontManager.light()
        nearByThreeLabel.textColor = ColorManager.subtitleTextColor
        nearByThreeLabel.layer.masksToBounds = true
        
        if viewModel?.isFavouriteLocation ?? false{
            updateFavouriteButton(favourite: true)
        }else{
            updateFavouriteButton(favourite: false)
        }
        
        distanceLabel.font = FontManager.regular()
        distanceLabel.textColor = ColorManager.textColor
        
        parkingTypeImageView.tintColor = ColorManager.subtitleTextColor
        
        parkingTypeLabel.font = FontManager.light()
        parkingTypeLabel.textColor = ColorManager.subtitleTextColor
        
        chargingTypeImageView.tintColor = ColorManager.subtitleTextColor
        
        chargingTypeLabel.font = FontManager.light()
        chargingTypeLabel.textColor = ColorManager.subtitleTextColor
        
        
    }
    @IBAction func directionButtonPressed(_ sender: Any) {
        viewModel?.openLocationInMaps()
    }
    @IBAction func addToFavouriteButtonPressed(_ sender: Any) {
        viewModel?.addToFavourtie(networkManager: NetworkManager(),completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let resoponse) :
                self.delegate?.addedTofavouriteResponse(response: resoponse, error: nil)
            case .failure(let error) :
                self.delegate?.addedTofavouriteResponse(response: nil, error: error)
            }
        
        })
        DispatchQueue.main.async{ [weak self] in
            guard let self = self else { return }
            self.updateFavouriteButton(favourite: true)
        }
    }
    func updateFavouriteButton(favourite : Bool){
        if favourite{
            addToFavouriteButton.setTitle(" Favourite", for: .normal)
            addToFavouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            addToFavouriteButton.setTitleColor(ColorManager.primaryTextColor, for: .normal)
            addToFavouriteButton.imageView?.tintColor = ColorManager.primaryTextColor
            addToFavouriteButton.isUserInteractionEnabled = false
        }else{
            addToFavouriteButton.setTitle(" Add to favourite", for: .normal)
            addToFavouriteButton.setImage(UIImage(systemName: "plus"), for: .normal)
            addToFavouriteButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
            addToFavouriteButton.imageView?.tintColor = ColorManager.subtitleTextColor
            addToFavouriteButton.isUserInteractionEnabled = true
        }
    }
    
    
    
}
