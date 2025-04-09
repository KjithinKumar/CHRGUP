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
        nearByOneLabel.text = ""
        nearByTwoLabel.text = ""
        nearByThreeLabel.text = ""
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
            statusLabel.textColor = ColorManager.primaryColor
        }else{
            statusLabel.text = "CLOSED"
            statusLabel.textColor = .red
        }
        distanceLabel.text = viewModel.distance + " Kms"
        distanceLabel.font = FontManager.bold(size: 17)
        
        let facilities = viewModel.facilities
        nearByOneLabel.text = ""
        nearByTwoLabel.text = ""
        nearByThreeLabel.text = ""
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
            pointsLabel.textColor = ColorManager.primaryColor
        }
    }
    func setShimmer(isShimmering : Bool){
        if isShimmering{
            configureUi()
            
            cellbackgroundView.startShimmering()
            cellbackgroundView.backgroundColor = .gray.withAlphaComponent(0.5)
            
            locationLabel.backgroundColor = .white
            locationLabel.textColor = .white
            locationLabel.startShimmering()
            locationLabel.layer.cornerRadius = 5
            
            pointsLabel.backgroundColor = .white
            pointsLabel.textColor = .white
            pointsLabel.startShimmering()
            pointsLabel.layer.cornerRadius = 5
            
            statusLabel.backgroundColor = .white
            statusLabel.textColor = .white
            statusLabel.startShimmering()
            statusLabel.layer.cornerRadius = 5
            
            
            nearByStackView.backgroundColor = .white
            nearByStackView.startShimmering()
            nearByStackView.layer.cornerRadius = 5
            
            nearByOneLabel.backgroundColor = .white
            nearByOneLabel.textColor = .white
            nearByTwoLabel.backgroundColor = .white
            nearByTwoLabel.textColor = .white
            nearByThreeLabel.backgroundColor = .white
            nearByThreeLabel.textColor = .white
            
            addToFavouriteButton.backgroundColor = .white
            addToFavouriteButton.imageView?.tintColor = .white
            addToFavouriteButton.setTitleColor(.white, for: .normal)
            addToFavouriteButton.startShimmering()
            addToFavouriteButton.layer.cornerRadius = 5
            
            parkingTypeLabel.backgroundColor = .white
            parkingTypeLabel.startShimmering()
            parkingTypeLabel.layer.cornerRadius = 5
            parkingTypeLabel.textColor = .white
            
            chargingTypeLabel.backgroundColor = .white
            chargingTypeLabel.startShimmering()
            chargingTypeLabel.layer.cornerRadius = 5
            chargingTypeLabel.textColor = .white
            
            distanceLabel.backgroundColor = .white
            distanceLabel.textColor = .white
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
            
            nearByStackView.backgroundColor = .clear
            nearByStackView.stopShimmering()
            
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
        
        locationLabel.font = FontManager.bold(size: 22)
        locationLabel.textColor = ColorManager.textColor
        
        pointsLabel.textColor = ColorManager.primaryColor
        pointsLabel.font = FontManager.light()
        
        statusLabel.textColor = ColorManager.primaryColor
        statusLabel.font = FontManager.regular()
        
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
        DispatchQueue.main.async{
            self.updateFavouriteButton(favourite: true)
        }
    }
    func updateFavouriteButton(favourite : Bool){
        if favourite{
            addToFavouriteButton.setTitle(" Favourite", for: .normal)
            addToFavouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            addToFavouriteButton.setTitleColor(ColorManager.primaryColor, for: .normal)
            addToFavouriteButton.imageView?.tintColor = ColorManager.primaryColor
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
