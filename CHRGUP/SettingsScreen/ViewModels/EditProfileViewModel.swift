//
//  EditProfileViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 01/04/25.
//

import Foundation

protocol EditProfileViewModelInterface{
    func updateUserProfile(userData : UserProfile,completion : @escaping(Result<UserLoginResponseModel,Error>)-> Void)
}

class EditProfileViewModel :  EditProfileViewModelInterface{
    var networkManager : NetworkManagerProtocol?
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func updateUserProfile(userData : UserProfile,completion : @escaping(Result<UserLoginResponseModel,Error>)-> Void) {
        guard let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else {return}
        let url = URLs.updateUserProfile(mobile: mobileNumber)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else {return}
        let header = ["Authorization": "Bearer \(authToken)"]
        let body = ["firstName" : userData.firstName,
                    "lastName" : userData.lastName,
                    "dob" : userData.dob,
                    "gender" : userData.gender]
        if let request = networkManager?.createRequest(urlString: url, method: .patch, body: body, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: UserLoginResponseModel.self, completion: { result in
                switch result {
                    case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
}
