//
//  GarageTableViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 12/03/25.
//

import UIKit

protocol GarageTableViewCellDelegate: AnyObject {
    func didTapEdit(at index: Int)
    func didTapDelete(at index: Int)
}

class GarageTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "GarageTableViewCell"

    @IBOutlet weak var backgroundViewTop: UIView!
    @IBOutlet weak var backgroundViewBottom: UIView!
    @IBOutlet weak var vehicleImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var vehicleNameLabel: UILabel!
    @IBOutlet weak var vehicleYearLabel: UILabel!
    @IBOutlet weak var vehicleVariantLabel: UILabel!
    
    weak var delegate: GarageTableViewCellDelegate?
    var indexPath : IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        backgroundViewTop.updateShimmerLayout()
        backgroundViewBottom.updateShimmerLayout()
    }

    
    func configure(with vehicle: VehicleModel, delegate : GarageTableViewCellDelegate, indexPath : IndexPath) {
        self.delegate = delegate
        self.indexPath = indexPath
        vehicleNameLabel.text = vehicle.make
        vehicleYearLabel.text = vehicle.model
        vehicleVariantLabel.text = vehicle.variant
        let imageString = URLs.imageUrl(vehicle.vehicleImg)
        let url = URL(string: imageString)
        vehicleImageView.sd_setImage(with: url)
    }
    
    func setShimmering(_ isShimmering: Bool) {
        backgroundViewTop.layer.cornerRadius = 10
        backgroundViewTop.clipsToBounds = true
        backgroundViewTop.backgroundColor = ColorManager.secondaryBackgroundColor
        backgroundViewBottom.backgroundColor = ColorManager.thirdBackgroundColor
        
        if isShimmering {
            backgroundViewTop.startShimmering()
            backgroundViewBottom.startShimmering()
            editButton.isHidden = true
            
            deleteButton.isHidden = true
            
            vehicleNameLabel.backgroundColor = .white
            vehicleNameLabel.layer.cornerRadius = 5
            vehicleNameLabel.startShimmering()
            
            vehicleYearLabel.backgroundColor = .white
            vehicleYearLabel.layer.cornerRadius = 5
            vehicleYearLabel.startShimmering()
            
            vehicleVariantLabel.backgroundColor = .white
            vehicleVariantLabel.layer.cornerRadius = 5
            vehicleVariantLabel.startShimmering()
            
            vehicleImageView.image = nil
            
            
        } else {
            vehicleNameLabel.tintColor = ColorManager.textColor
            vehicleNameLabel.font = FontManager.regular()
            vehicleNameLabel.stopShimmering()
            vehicleNameLabel.backgroundColor = .clear
            
            vehicleYearLabel.tintColor = ColorManager.textColor
            vehicleYearLabel.font = FontManager.regular(size: 12)
            vehicleYearLabel.stopShimmering()
            vehicleYearLabel.backgroundColor = .clear
            
            vehicleVariantLabel.tintColor = ColorManager.textColor
            vehicleVariantLabel.font = FontManager.regular(size: 12)
            vehicleVariantLabel.stopShimmering()
            vehicleVariantLabel.backgroundColor = .clear
            
            backgroundViewTop.stopShimmering()
            backgroundViewBottom.stopShimmering()
            vehicleImageView.stopShimmering()
            vehicleImageView.backgroundColor = .clear
            
            editButton.imageView?.tintColor = ColorManager.textColor
            editButton.isHidden = false
            
            deleteButton.imageView?.tintColor = ColorManager.textColor
            deleteButton.isHidden = false
            
        }
    }
    @IBAction func editButtonPressed(_ sender: Any) {
        guard let index = indexPath?.row else { return }
        delegate?.didTapEdit(at: index)
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
        guard let index = indexPath?.row else { return }
        delegate?.didTapDelete(at: index)
    }
    
}
