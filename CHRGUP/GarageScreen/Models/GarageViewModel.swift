//
//  GarageViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 12/03/25.
//

import Foundation
protocol GarageViewModelDelegate: AnyObject {
    func receivedVehicleDetails()
    func didUpdateGarage(_ vehicle: VehicleModel)
    func didFailWithError(_ error: String, _ code : Int)
    func didDeletedVehicle(_ message : String)
}

protocol GarageViewModelInterface{
    func fetchVehicles()
    func getVehicles() -> [VehicleModel]?
    func deleteVehicle(vehicleId : String)
}

class GarageViewModel : GarageViewModelInterface {
    var networkManager: NetworkManager?
    weak var delegate: GarageViewModelDelegate?
    var userData : UserProfile?
    var mobileNumber : String?
    var authToken : String?
    var userVehicles : [VehicleModel]?
    init(networkManager: NetworkManager, delegate: GarageViewModelDelegate) {
        self.networkManager = networkManager
        self.delegate = delegate
        fetchUserDetailsFromUserDefaults()
    }
    
    func fetchUserDetailsFromUserDefaults() {
        userData = UserDefaultManager.shared.getUserProfile()
        if let userData = userData {
            mobileNumber = userData.phoneNumber
            authToken = UserDefaultManager.shared.getJWTToken()
        }
    }
    
    func fetchVehicles() {
        guard let mobileNumber = mobileNumber, let authToken = authToken else {
            return
        }
        let url = URLs.userVehiclesUrl(mobileNumber: mobileNumber)
        let header = ["Authorization": "Bearer \(authToken)"]
        let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header)
        if let request = request {
            networkManager?.request(request, decodeTo: UserVehicleResponse.self, completion: { result in
                switch result {
                case .success(let response) :
                    self.userVehicles = response.data
                    self.delegate?.receivedVehicleDetails()
                case .failure(let error):
                    if let error = error as? NetworkManagerError{
                        switch error{
                        case .serverError(let message,let code) :
                            self.delegate?.didFailWithError(message,code)
                        default :
                            break
                        }
                    }
                    debugPrint(error)
                }
            })
        }
    }
    func getVehicles() -> [VehicleModel]? {
        return userVehicles
    }
    func deleteVehicle(vehicleId : String) {
        guard let mobileNumber = mobileNumber, let authToken = authToken else {
            return
        }
        let url = URLs.deleteVehicleUrl(mobileNumber: mobileNumber, VehicleId: vehicleId)
        guard let request = networkManager?.createRequest(urlString: url, method: .delete, body: nil, encoding: .json, headers: ["Authorization": "Bearer \(authToken)"]) else {
            return
        }
        networkManager?.request(request, decodeTo: newVehicleResponse.self, completion: { result in
            switch result {
            case .success(let response):
                let message = response.message
                self.delegate?.didDeletedVehicle(message ?? "Vehicle Deleted Successfully")
            case .failure(let error):
                if let error = error as? NetworkManagerError{
                    switch error{
                    case .serverError(let message,let code) :
                        self.delegate?.didFailWithError(message,code)
                    default :
                        break
                    }
                }else{
                    debugPrint(error)
                }
            }
        })
    }
    
}
