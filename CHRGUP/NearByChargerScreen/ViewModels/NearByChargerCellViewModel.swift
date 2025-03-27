//
//  NearByChargerCellViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/03/25.
//

import Foundation
import UIKit

class NearByChargerCellViewModel{
    var chargerLocationData : ChargerLocation
    var networkManager : NetworkManagerProtocol?
    init (chargerLocationData : ChargerLocation) {
        self.chargerLocationData = chargerLocationData
    }
    var locationName : String {
        return chargerLocationData.locationName
    }
    var parkingTypeText: String {
        return chargerLocationData.freePaid.parking ? "Free Parking" : "Paid Parking"
    }

    var parkingTypeColor: UIColor {
        return chargerLocationData.freePaid.parking ? ColorManager.primaryColor : ColorManager.subtitleTextColor
    }

    var chargingTypeText: String {
        return chargerLocationData.freePaid.charging ? "Free Charging" : "Paid Charging"
    }

    var chargingTypeColor: UIColor {
        return chargerLocationData.freePaid.charging ? ColorManager.primaryColor : ColorManager.subtitleTextColor
    }
    
    var distance : String {
        return chargerLocationData.modDistance ?? "0"
    }
    var chargerLocationAvailable : Bool {
        return chargerLocationData.modLocationAvailble ?? false
    }
    var facilities : [String] {
        var names : [String] = []
        if let facility = chargerLocationData.facilities {
            names = facility.map { $0.name }
        }
        return names
    }
    var pointsAvailable : Int {
        return chargerLocationData.modpointsAvailable ?? 0
    }
    
    var isFavouriteLocation : Bool {
        let favourites = UserDefaultManager.shared.getFavouriteLocations()
        let locationId = chargerLocationData.id
        return favourites.contains(where: { $0 == locationId })
    }
    
    func openLocationInMaps() {
        let latitude = chargerLocationData.direction.latitude
        let longitude = chargerLocationData.direction.longitude
        let appleMapsURL = "http://maps.apple.com/?q=\(latitude),\(longitude)&dirflg=d"
        let googleMapsURL = "comgooglemaps://?q=\(latitude),\(longitude)&directionsmode=driving"

        if let googleMaps = URL(string: googleMapsURL), UIApplication.shared.canOpenURL(googleMaps) {
            UIApplication.shared.open(googleMaps, options: [:], completionHandler: nil) // Open Google Maps
        } else if let appleMaps = URL(string: appleMapsURL) {
            UIApplication.shared.open(appleMaps, options: [:], completionHandler: nil) // Open Apple Maps
        }
    }
    
    
    
    func addToFavourtie(networkManager : NetworkManagerProtocol,completion: @escaping (Result<FavouriteResponseModel, Error>) -> Void){
        let locationId = chargerLocationData.id
        UserDefaultManager.shared.saveFavouriteLocation(locationId)
        let userDetails = UserDefaultManager.shared.getUserProfile()
        guard let mobileNumber = userDetails?.phoneNumber else {
            return
        }
        let url = URLs.addFavouriteLocationUrl(mobileNumber: mobileNumber)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let requestBody : [String : Any] = ["locationId" : locationId]
        let header = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager.createRequest(urlString: url, method: .post, body: requestBody, encoding: .json, headers: header){
            networkManager.request(request, decodeTo: FavouriteResponseModel.self) { result in
                switch result{
                case .success(let response):
                    completion(.success(response))
                case .failure(let error) :
                    completion(.failure(error))
                }
            }
        }
        
    }
}

