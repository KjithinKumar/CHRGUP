//
//  UserRegistrationViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 10/03/25.
//

import Foundation
protocol UserRegistrationViewModelDelegate: AnyObject {
    func didSaveUserProfileSuccessfully(token: String?)
    func didAddedNewVehicleSuccessfully(message : String?)
    func failedToAddNewVehicle(_ error : String,_ code : Int)
    func didUpdateVehicleSuccessfully(message: String?)
    func didFailToSaveUserProfile(error: String)
}
protocol UserRegistrationViewModelnterface{
    func saveUserProfile(userProfile: UserProfile)
    func addNewVehicle(vehicle: VehicleModel,mobileNumber: String)
    func updateVehicle(vehicle: VehicleModel,mobileNumber: String,vehicleId: String)
}

class UserRegistrationViewModel : UserRegistrationViewModelnterface{
    weak var delegate: UserRegistrationViewModelDelegate?
    var networkManager: NetworkManager?
    
    init(delegate: UserRegistrationViewModelDelegate, networkManager: NetworkManager) {
        self.delegate = delegate
        self.networkManager = networkManager
    }
    
    func saveUserProfile(userProfile: UserProfile) {
        let url = URLs.postUserUrl
        guard let request = networkManager?.createRequest(urlString: url,
                                                          method: .post,
                                                          body: userProfile.toDictionary(),
                                                          encoding: .json,
                                                          headers: nil) else{
            delegate?.didFailToSaveUserProfile(error: "Invalid Request")
            return
        }
        networkManager?.request(request,
                                decodeTo: UserLoginResponseModel.self, completion: { result in
            switch result {
            case .success(let userResponse):
                debugPrint(userResponse)
                self.delegate?.didSaveUserProfileSuccessfully(token: userResponse.token)
            case .failure(let error) :
                self.delegate?.didFailToSaveUserProfile(error: error.localizedDescription)
            }
        })
    }
    func addNewVehicle(vehicle: VehicleModel,mobileNumber: String) {
        let url = URLs.userVehiclesUrl(mobileNumber: mobileNumber)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else {
            return
        }
        let header = ["Authorization": "Bearer \(authToken)"]
        guard let request = networkManager?.createRequest(urlString: url,
                                                          method: .post,
                                                          body: vehicle.toDictionary(),
                                                          encoding: .json,
                                                          headers: header) else{
            delegate?.didFailToSaveUserProfile(error: "Invalid Request")
            return
        }
        networkManager?.request(request, decodeTo: newVehicleResponse.self, completion: { result in
            switch result {
            case .success(let response):
                self.delegate?.didAddedNewVehicleSuccessfully(message: response.message)
            case .failure(let error) :
                if let error = error as? NetworkManagerError{
                    switch error{
                    case .serverError(let message,let code) :
                        self.delegate?.failedToAddNewVehicle(message, code)
                    default :
                        debugPrint(error)
                    }
                }else{
                    debugPrint(error)
                }
            }
        })
    }
    func updateVehicle(vehicle: VehicleModel,mobileNumber: String,vehicleId: String){
        let url = URLs.updateVehicleUrl(mobileNumber: mobileNumber, VehicleId: vehicleId)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else {
            return
        }
        let header = ["Authorization": "Bearer \(authToken)"]
        guard let request = networkManager?.createRequest(urlString: url,
                                                          method: .put,
                                                          body: vehicle.toDictionary(),
                                                          encoding: .json, headers: header) else {return}
        networkManager?.request(request, decodeTo: newVehicleResponse.self, completion: { result in
            switch result {
            case .success(let response):
                self.delegate?.didUpdateVehicleSuccessfully(message: response.message)
            case .failure(let error) :
                if let error = error as? NetworkManagerError{
                    switch error{
                    case .serverError(let message,let code) :
                        self.delegate?.failedToAddNewVehicle(message, code)
                    default :
                        debugPrint(error)
                    }
                }else{
                    debugPrint(error)
                }
            }
        })
    }
    
}
