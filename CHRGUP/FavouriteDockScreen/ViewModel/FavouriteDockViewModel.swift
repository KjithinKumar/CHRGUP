//
//  FavouriteDockViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 27/03/25.
//

import Foundation
import CoreLocation

protocol FavouriteDockViewModelInterface: AnyObject {
    var favouriteLocation : [ChargerLocation]? { get set }
    func getUserFavouriteLocation(completion : @escaping (Result<GetFavouriteResponseModel, Error>) -> Void)
    func removeFavouriteLocation(locationId : String, completion : @escaping (Result<FavouriteResponseModel, Error>) -> Void)
    func addToFavourtie(at index : Int,completion: @escaping (Result<FavouriteResponseModel, Error>) -> Void)
}


class FavouriteDockViewModel: FavouriteDockViewModelInterface{
    var networkManager : NetworkManagerProtocol?
    let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    var favouriteLocation : [ChargerLocation]?
    
    func getUserFavouriteLocation(completion : @escaping (Result<GetFavouriteResponseModel, Error>) -> Void){
        if let mobileNumber = mobileNumber{
           let url = URLs.getFavouriteLocationUrl(mobileNumber: mobileNumber)
            guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
            let header = ["Authorization": "Bearer \(authToken)"]
            if let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header){
                networkManager?.request(request, decodeTo: GetFavouriteResponseModel.self, completion: { result in
                    switch result{
                    case .success(let response):
                        if let currentLocation = UserDefaultManager.shared.getUserCurrentLocation(){
                            let location = CLLocation(latitude: currentLocation.first ?? 0.0, longitude: currentLocation.last ?? 0.0)
                            let processedLocations = response.data.map { ChargerLocationProcessor.process($0, currentLocation: location) }
                            self.favouriteLocation = processedLocations
                        }
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            }
        }
    }
    func removeFavouriteLocation(locationId : String, completion : @escaping (Result<FavouriteResponseModel, Error>) -> Void){
        if let mobileNumber = mobileNumber{
            let url = URLs.deleteFavouriteLocationUrl(mobileNumber: mobileNumber)
            guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
            let requestBody : [String : Any] = ["locationId" : locationId]
            let header = ["Authorization": "Bearer \(authToken)"]
            if let request = networkManager?.createRequest(urlString: url, method: .delete, body: requestBody, encoding: .json, headers: header){
                networkManager?.request(request, decodeTo: FavouriteResponseModel.self, completion: { result in
                    switch result{
                    case .success(let response):
                        if response.status{
                            UserDefaultManager.shared.removeFavouriteLocation(locationId)
                        }
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            }
        }
    }
    func addToFavourtie(at index : Int,completion: @escaping (Result<FavouriteResponseModel, Error>) -> Void){
        let locationId = favouriteLocation?[index].id ?? ""
        let userDetails = UserDefaultManager.shared.getUserProfile()
        guard let mobileNumber = userDetails?.phoneNumber else {
            return
        }
        let url = URLs.addFavouriteLocationUrl(mobileNumber: mobileNumber)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let requestBody : [String : Any] = ["locationId" : locationId]
        let header = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: requestBody, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: FavouriteResponseModel.self) { result in
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
    func getProcessedFavouriteCharger(latitude : Double, longitude : Double, charger: ChargerLocation) -> ChargerLocation {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return ChargerLocationProcessor.process(charger, currentLocation: location)
    }
}
