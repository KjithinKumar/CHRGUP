//
//  LocationInfoViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/03/25.
//

import Foundation

enum locationInfoCellType{
    case chargers
    case tarrif
    case facilities
    case titleSubTitle(TitleSubtitleType)
}
enum TitleSubtitleType {
    case workingHours
    case address
    case contact
}

protocol LocationInfoViewModelInterface{
    var locationData : ChargerLocation? {get}
    var userLocationlatitude : Double? {get}
    var userLocationlongitude : Double? {get}
    var locationName : String {get}
    var distance : String {get}
    var isAvailable : Bool {get}
    var isFavourite : Bool {get}
    var locationImage : [String] {get}
    var locationCellType : [locationInfoCellType] {get}
    var pointsAvailable : String {get}
    func addToFavourtie(networkManager : NetworkManagerProtocol,completion: @escaping (Result<FavouriteResponseModel, Error>) -> Void)
    var locationLatitude : Double {get}
    var locationLongitude : Double {get}
    
}

class LocationInfoViewModel : LocationInfoViewModelInterface{
    
    
    var locationData : ChargerLocation?
    var userLocationlatitude : Double?
    var userLocationlongitude : Double?
    init(locationData: ChargerLocation,latitude : Double,longitude : Double) {
        self.locationData = locationData
        self.userLocationlatitude = latitude
        self.userLocationlongitude = longitude
    }
    
    var locationName : String {
        return locationData?.locationName ?? "location"
    }
    var distance : String {
        return "\(locationData?.modDistance ?? "0") Kms"
    }
    var isAvailable : Bool {
        return locationData?.modLocationAvailble ?? false
    }
    var isFavourite: Bool {
        let userFavourite = UserDefaultManager.shared.getFavouriteLocations()
        return userFavourite.contains(where: { $0 == locationData?.id })
    }
    var locationImage : [String]{
        return locationData?.locationImage ?? []
    }
    var locationLatitude : Double {
        return locationData?.direction.latitude ?? 0
    }
    var locationLongitude : Double {
        return locationData?.direction.longitude ?? 0
    }
    
    var locationCellType : [locationInfoCellType] = [.chargers,.tarrif,.facilities,.titleSubTitle(.workingHours),.titleSubTitle(.address),.titleSubTitle(.contact)]
    
    var pointsAvailable : String {
        return "\(locationData?.modpointsAvailable ?? 0)"
    }
    func addToFavourtie(networkManager : NetworkManagerProtocol,completion: @escaping (Result<FavouriteResponseModel, Error>) -> Void){
        let locationId = locationData?.id ?? ""
        let userDetails = UserDefaultManager.shared.getUserProfile()
        guard let mobileNumber = userDetails?.phoneNumber else {
            return
        }
        let url = URLs.addFavouriteLocationUrl(mobileNumber: mobileNumber)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let requestBody : [String : Any] = ["locationId" : locationId]
        let header = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager.createRequest(urlString: url, method: .post, body: requestBody, encoding: .json, headers: header){
            networkManager.request(request, decodeTo: FavouriteResponseModel.self) { [weak self] result in
                guard let _ = self else { return }
                switch result{
                case .success(let response):
                    UserDefaultManager.shared.saveFavouriteLocation(locationId)
                    completion(.success(response))
                case .failure(let error) :
                    completion(.failure(error))
                }
            }
        }
    }
    
}
