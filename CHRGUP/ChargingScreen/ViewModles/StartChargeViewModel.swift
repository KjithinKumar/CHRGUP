//
//  StartChargeViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/04/25.
//

import Foundation

protocol StartChargeViewModelInterface {
    func chargerDetails() -> ChargerLocationData?
    func startCharging(phoneNumber: String, qrpayload : QRPayload,completion : @escaping( Result<StartChargeResponseModel,Error>) -> Void)
}

class StartChargeViewModel: StartChargeViewModelInterface {
    var chargerInfo : ChargerLocationData?
    var networkManager : NetworkManagerProtocol?
    
    init(chargerInfo: ChargerLocationData, networkManager: NetworkManagerProtocol) {
        self.chargerInfo = chargerInfo
        self.networkManager = networkManager
    }
    func chargerDetails() -> ChargerLocationData? {
        guard let chargerInfo = chargerInfo else {
            return nil
        }
        return chargerInfo 
    }
    func startCharging(phoneNumber: String, qrpayload : QRPayload,completion : @escaping( Result<StartChargeResponseModel,Error>) -> Void){
        let vehicleId = UserDefaultManager.shared.getSelectedVehicle()?.id ?? ""
        let payloadRequest = payload(idTag: phoneNumber, connectorId: qrpayload.connectorId)
        let requestModel = StartChargingRequest(action: "start",
                                                chargerId: qrpayload.chargerId,
                                                vehicleId: vehicleId,
                                                payload: payloadRequest,
                                                sessionReason: "User done it remotely.")
        let url = URLs.startChargingUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: requestModel.toDictionary(), encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: StartChargeResponseModel.self) { [weak self] result in
                guard let _ = self else { return }
                switch result {
                case .success(let response):
                    if response.status{
                        UserDefaultManager.shared.saveChargerId(qrpayload.chargerId)
                        UserDefaultManager.shared.saveTimestamp()
                    }
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

}
