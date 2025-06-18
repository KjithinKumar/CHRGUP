//
//  ReserveChargerViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 30/05/25.
//

import Foundation
protocol ReserveChargerViewModelInterface {
    var connectorItems : [ConnectorDisplayItem] {get set}
    func makeReservation(for connector : ConnectorDisplayItem, endTime : String) async throws -> ReservationResponseModel
}
class ReserveChargerViewModel: ReserveChargerViewModelInterface {
    var chargersInfo : [ChargerInfo]?
    var networkManger : NetworkManagerProtocol?
    var connectorItems : [ConnectorDisplayItem] = []
    init(connectorItems : [ConnectorDisplayItem], networkManger: NetworkManagerProtocol) {
        self.connectorItems = connectorItems
        self.networkManger = networkManger
    }
    func makeReservation(for connector : ConnectorDisplayItem, endTime : String) async throws -> ReservationResponseModel{
        let url = URLs.reservationUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { throw NetworkManagerError.invalidRequest }
        guard let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else { throw NetworkManagerError.invalidRequest }
        let header = ["Authorization": "Bearer \(authToken)"]
        guard let chargerId = connector.chargerInfo.name else { throw NetworkManagerError.invalidRequest }
        let connectorId = connector.connector.connectorId
        let requestBody : [String : Any] = ["idTag" : mobileNumber ,
                                            "chargerId" : chargerId,
                                            "connectorId" : connectorId,
                                            "endTime" : endTime,
                                            "timezone" : AppConstants.timeZone]
        guard let request = networkManger?.createRequest(urlString: url, method: .post, body: requestBody, encoding: .json, headers: header)else {throw NetworkManagerError.invalidRequest}
        
        return try await withCheckedThrowingContinuation { continuation in
            networkManger?.request(request, decodeTo: ReservationResponseModel.self) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
