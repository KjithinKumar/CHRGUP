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
    var locationData : LocationData? {get}
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
    func updateConnectorStatus (_ updatedConnector: ConnectorDisplayItem)
    var connectorItems : [ConnectorDisplayItem] { get} 
}

class LocationInfoViewModel : LocationInfoViewModelInterface{
    var locationData : LocationData?
    var userLocationlatitude : Double?
    var userLocationlongitude : Double?
    var connectorItems : [ConnectorDisplayItem] = []
    init(locationData: LocationData,latitude : Double,longitude : Double) {
        self.locationData = locationData
        self.userLocationlatitude = latitude
        self.userLocationlongitude = longitude
        loadConnectors()
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
    func loadConnectors(){
        if let chargerData = locationData?.chargerInfo{
            for charger in chargerData{
                if let connectors = charger.connectors{
                    for connector in connectors{
                        connectorItems.append(ConnectorDisplayItem(chargerInfo: charger, connector: connector))
                    }
                }
            }
        }
        let statusPriority: [String: Int] = ["Available": 0, "Inactive": 2]
        connectorItems = connectorItems.sorted {
            (statusPriority[$0.connector.status] ?? 1) < (statusPriority[$1.connector.status] ?? 1)
        }
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

    func updateConnectorStatus (_ updatedConnector: ConnectorDisplayItem) {
        if let index = connectorItems.firstIndex(where: { $0.connector.connectorId == updatedConnector.connector.connectorId}) {
            connectorItems[index].connector.status = "InUse"
            locationData?.modpointsAvailable = connectorItems.filter({ $0.connector.status == "Available" }).count
        }
    }
    
}
