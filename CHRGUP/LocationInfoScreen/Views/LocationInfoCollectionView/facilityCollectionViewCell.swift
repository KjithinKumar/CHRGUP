//
//  facilityCollectionViewCell.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/03/25.
//

import UIKit

class facilityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var facilityImageView: UIImageView!
    @IBOutlet weak var facilityLabel: UILabel!
    static let identifier = "facilityCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configure(facility: Facility){
        facilityLabel.text = facility.name
        facilityLabel.font = FontManager.light()
        facilityLabel.textColor = ColorManager.textColor
        
        facilityImageView.tintColor = ColorManager.textColor
        facilityImageView.image = FacilityManager().getIcon(for: facility)
        facilityImageView.layer.cornerRadius = facilityImageView.frame.width / 2
        facilityImageView.layer.masksToBounds = true
        facilityImageView.backgroundColor = ColorManager.thirdBackgroundColor
    }

}
struct FacilityManager {
    private let sfSymbolMapping: [String: String] = [
        "Toilets": "figure.stand.dress.line.vertical.figure",
        "Wi-Fi Zones": "wifi",
        "Parking": "parkingsign",
        "Restaurants": "fork.knife",
        "Petrol Pumps": "fuelpump.fill",
        "Shopping Centers": "bag.fill",
        "Hotels": "bed.double.fill",
        "Cafes": "cup.and.saucer.fill",
        "ATM": "banknote.fill",
        "Pharmacies": "pills.fill",
        "Rest Areas": "figure.rest.circle.fill",
        "Grocery Stores": "cart.fill",
        "EV Maintenance Services": "wrench.and.screwdriver.fill",
        "Car Wash": "car.fill",
        "Recreational Areas": "leaf.fill",
        "Fitness Centers": "figure.run",
        "Cultural Sites": "building.columns.fill",
        "Public Transportation Hubs": "bus.fill"
    ]

    func getIcon(for facility: Facility) -> UIImage? {
        guard let symbolName = sfSymbolMapping[facility.name] else { return nil }
        return UIImage(systemName: symbolName)
    }
}
