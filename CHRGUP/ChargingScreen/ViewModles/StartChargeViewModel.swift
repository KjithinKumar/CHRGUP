//
//  StartChargeViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/04/25.
//

import Foundation

protocol StartChargeViewModelInterface {
    var chargerDetails: ChargerLocationData? { get }
    func startCharging(phoneNumber: String, qrpayload : QRPayload,completion : @escaping( Result<StartChargeResponseModel,Error>) -> Void)
    func paymentStatus(completion : @escaping( Result<PaymentStatusResponse,Error>) -> Void)
    func pushLiveApnToken(apnToken: String, event : String ,completion: @escaping (Result<apnTokenResponse, Error>) -> Void)
}

class StartChargeViewModel: StartChargeViewModelInterface {
    var networkManager : NetworkManagerProtocol?
    var chargerDetails: ChargerLocationData?
    init(chargerInfo: ChargerLocationData, networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        self.chargerDetails = chargerInfo
    }
    func startCharging(phoneNumber: String, qrpayload : QRPayload,completion : @escaping( Result<StartChargeResponseModel,Error>) -> Void){
        let vehicleId = UserDefaultManager.shared.getSelectedVehicle()?.id ?? ""
        let payloadRequest = StartChargingpayload(idTag: phoneNumber, connectorId: qrpayload.connectorId)
        let requestModel = StartChargingRequest(action: "start",
                                                chargerId: qrpayload.chargerId,
                                                vehicleId: vehicleId,
                                                payload: payloadRequest,
                                                sessionReason: "User done it remotely.")
        let url = URLs.sessionTransationUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: requestModel.toDictionary(), encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: StartChargeResponseModel.self) { [weak self] result in
                guard let _ = self else { return }
                switch result {
                case .success(let response):
                    if response.status{
                        UserDefaultManager.shared.saveChargerId(qrpayload.chargerId)
                        if let sessionId = response.sessionId {
                            UserDefaultManager.shared.saveSessionId(sessionId)
                        }
                        UserDefaultManager.shared.saveTimestamp()
                    }
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    func paymentStatus(completion : @escaping( Result<PaymentStatusResponse,Error>) -> Void){
        let url = URLs.paymentStatusUrl
        guard let sessionID = UserDefaultManager.shared.getSessionId() else { return }
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        let body : [String:Any] = ["sessionId":sessionID]
        if let requset = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(requset, decodeTo: PaymentStatusResponse.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
    func pushLiveApnToken(apnToken: String, event : String ,completion: @escaping (Result<apnTokenResponse, Error>) -> Void) {
        let url = URLs.apnUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header: [String: String] = ["Authorization": "Bearer \(authToken)"]
        guard let sessionId = UserDefaultManager.shared.getSessionId() else {return}
        let body : [String:Any] = ["deviceToken":apnToken,
                                   "sessionId" : sessionId,
                                   "event" : event]
        if let requset = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(requset, decodeTo: apnTokenResponse.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
}
