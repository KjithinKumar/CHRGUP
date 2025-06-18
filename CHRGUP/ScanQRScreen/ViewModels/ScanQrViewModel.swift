//
//  ScanQrViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 07/04/25.
//

import Foundation

protocol ScanQrViewModelInterface {
    func fetchChargerDetails(id : String, connectorId : Int ,completion : @escaping (Result<ChargerNameResponse,Error>) -> Void)
}

class ScanQrViewModel: ScanQrViewModelInterface {
    var networkManager: NetworkManagerProtocol?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    func fetchChargerDetails(id : String, connectorId : Int ,completion : @escaping (Result<ChargerNameResponse,Error>) -> Void){
        let url = URLs.getChargerByName
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        let body = ["chargerName" : id,
                    "connectorId" : connectorId] as [String : Any]
        if let reqest = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(reqest, decodeTo: ChargerNameResponse.self , completion: { [weak self] result in
                guard let _ = self else { return }
                switch result {
                case .success(let response):
                    if let locationId = response.data?.location?.locationId{
                        UserDefaultManager.shared.saveScannedLocation(locationId)
                    }
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
}
