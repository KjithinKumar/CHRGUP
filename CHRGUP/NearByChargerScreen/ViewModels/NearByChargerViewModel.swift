//
//  NearByChargerViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 19/03/25.
//

import Foundation
import CoreLocation

protocol NearByChargerViewModelDelegate: AnyObject {
    
    
}

protocol NearByChargerViewModelInterface{
    func getNearByCharger(latitue: Double, longitude: Double, range : Int, mobileNumber: String, completion : @escaping (Result<ChargerLocationResponse, Error>) -> Void)
    func nearByChargerData() -> [ChargerLocation]
    func sortedNearByChargerData(currentLocation : CLLocation) -> [ChargerLocation]
}
class NearByChargerViewModel : NearByChargerViewModelInterface{
    var networkManager: NetworkManagerProtocol?
    weak var delegate : NearByChargerViewModelDelegate?
    var chargerLocationResponse : ChargerLocationResponse?
    
    init(networkManager: NetworkManagerProtocol, delegate: NearByChargerViewModelDelegate) {
        self.networkManager = networkManager
        self.delegate = delegate
    }
    
    func getNearByCharger(latitue: Double, longitude: Double, range : Int, mobileNumber: String, completion : @escaping (Result<ChargerLocationResponse, Error>) -> Void){
        let url = URLs.nearByChargersUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let body = ["latitude": latitue, "longitude": longitude, "range": range, "mobileNumber": mobileNumber] as [String : Any]
        let header = ["Authorization": "Bearer \(authToken)"]
        if let reqest = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(reqest, decodeTo: ChargerLocationResponse.self , completion: { result in
                switch result {
                case .success(let response):
                    self.chargerLocationResponse = response
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
    func nearByChargerData() -> [ChargerLocation]{
        return chargerLocationResponse?.data ?? []
    }
    
    func sortedNearByChargerData(currentLocation : CLLocation) -> [ChargerLocation]{
        let locationsList = nearByChargerData()
        let updateChargerLocations = locationsList.map { charger -> ChargerLocation in
            let chargerLocation = CLLocation(latitude: charger.direction.latitude, longitude: charger.direction.longitude)
            var updatedCharger = charger
            updatedCharger.distance = currentLocation.distance(from: chargerLocation)/1000
            return updatedCharger
        }
        
        return updateChargerLocations.sorted { ($0.distance) ?? 0 < ($1.distance) ?? 0}
    }
    
    
}
