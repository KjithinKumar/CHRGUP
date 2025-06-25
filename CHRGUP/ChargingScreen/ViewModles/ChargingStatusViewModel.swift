//
//  ChargingStatusViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 12/04/25.
//

import Foundation
protocol ChargingStatusViewModelInterface{
    func fetchChargingStatus(completion : @escaping (Result<ChargingStatusResponseModel, Error>) -> Void)
    //func getFormattedTimeDifference(from dateString: String) -> NSAttributedString
    func stopCharging(completion : @escaping( Result<StopChargingResponseModel,Error>) -> Void)
    func pushLiveApnToken(apnToken: String, event : String ,completion: @escaping (Result<apnTokenResponse, Error>) -> Void)
}
class ChargingStatusViewModel: ChargingStatusViewModelInterface {
    var networkManager: NetworkManagerProtocol?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    func fetchChargingStatus(completion : @escaping (Result<ChargingStatusResponseModel, Error>) -> Void){
        let url = URLs.getChargingStatusUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        guard let phoneNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else { return }
        let body : [String:Any] = ["userPhone":phoneNumber,
                                   "timezone":AppConstants.timeZone]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: ChargingStatusResponseModel.self) { [weak self] result in
                guard let _ = self else { return }
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    func stopCharging(completion : @escaping( Result<StopChargingResponseModel,Error>) -> Void){
        let chargerId = UserDefaultManager.shared.getChargerId() ?? ""
        let sessionId = UserDefaultManager.shared.getSessionId() ?? ""
        let payloadRequest = StopChargingPayload(sessionId: sessionId)
        let url = URLs.sessionTransationUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        let requestModel = StopChargingRequest(action: "stop",
                                               chargerId: chargerId,
                                               payload: payloadRequest,
                                               sessionId: sessionId,
                                               sessionReason: "User done it remotely.")
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: requestModel.toDictionary(), encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: StopChargingResponseModel.self) { [weak self] result in
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
