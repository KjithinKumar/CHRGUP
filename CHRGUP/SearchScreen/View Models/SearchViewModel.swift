//
//  SearchViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 02/04/25.
//

import Foundation
import CoreLocation

protocol SearchViewModelInterface {
    var chargers : [LocationData]? { get set }
    func fetchChargers(string : String ,completion : @escaping (Result<ChargerLocationResponse, Error>) -> Void)
    var recentChargers: [LocationData] { get }
    func addRecentCharger(_ charger: LocationData)
    func refreshLocationData(id : String,completion : @escaping (Result<LocationData, Error>) -> Void)
}

class SearchViewModel: SearchViewModelInterface {
    var networkManager : NetworkManagerProtocol?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    var chargers : [LocationData]?
    var recentChargers: [LocationData] {
        get {
            guard let storedChargers = UserDefaultManager.shared.getRecentChargers(),
                  let currentLocation = UserDefaultManager.shared.getUserCurrentLocation() else {
                return []
            }
            
            let location = CLLocation(latitude: currentLocation.first ?? 0.0,
                                      longitude: currentLocation.last ?? 0.0)
            
            return storedChargers.map { ChargerLocationProcessor.process($0, currentLocation: location) }
        }
        set{
            UserDefaultManager.shared.saveRecentChargers(newValue)
        }
    }
    
    func fetchChargers(string : String ,completion : @escaping (Result<ChargerLocationResponse, Error>) -> Void){
        let url = URLs.searchChargersUrl(searchText: string)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        if let reqest = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header){
            networkManager?.request(reqest, decodeTo: ChargerLocationResponse.self , completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if let currentLocation = UserDefaultManager.shared.getUserCurrentLocation(){
                        let location = CLLocation(latitude: currentLocation.first ?? 0.0, longitude: currentLocation.last ?? 0.0)
                        if let locations = response.data{
                            let processedLocations = locations.map { ChargerLocationProcessor.process($0, currentLocation: location) }
                            self.chargers = processedLocations
                        }
                    }
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
    func addRecentCharger(_ charger: LocationData) {
        if let index = recentChargers.firstIndex(where: { $0.id == charger.id }) {
            recentChargers.remove(at: index) // Remove if already present to move it to top
        }
        recentChargers.insert(charger, at: 0) // Add new at the beginning
        if recentChargers.count > 5 {
            recentChargers.removeLast() // Keep only last 5
        }
    }
    func refreshLocationData(id : String,completion : @escaping (Result<LocationData, Error>) -> Void){
        let url = URLs.getChargerByIdUrl(chargerId: id)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        if let reqest = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header){
            networkManager?.request(reqest, decodeTo: ChargerLocationUpdateResopnse.self , completion: { [weak self] result in
                guard let _ = self else { return }
                switch result {
                case .success(let response):
                    if let currentLocation = UserDefaultManager.shared.getUserCurrentLocation(){
                        let location = CLLocation(latitude: currentLocation.first ?? 0.0, longitude: currentLocation.last ?? 0.0)
                        if let locations = response.data{
                            let processedLocation =  ChargerLocationProcessor.process(locations, currentLocation: location)
                            completion(.success(processedLocation))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
    
}
