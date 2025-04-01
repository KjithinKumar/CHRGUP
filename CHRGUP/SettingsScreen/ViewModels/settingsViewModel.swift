//
//  settingsViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 01/04/25.
//

import Foundation

protocol settingsViewModelInterface {
    func deletUserAccount(mobileNumber : String, completion : @escaping (Result<DeleteUserModel, Error>) -> Void)
}

class settingsViewModel: settingsViewModelInterface {
    var networkManager: NetworkManagerProtocol?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func deletUserAccount(mobileNumber : String, completion : @escaping (Result<DeleteUserModel, Error>) -> Void) {
        let url = URLs.updateUserProfile(mobile: mobileNumber)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else {return}
        let header = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager?.createRequest(urlString: url, method: .delete, body: nil, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: DeleteUserModel.self, completion: { result in
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
