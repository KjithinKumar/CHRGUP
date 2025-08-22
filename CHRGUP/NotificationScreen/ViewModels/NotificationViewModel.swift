//
//  NotificationViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/07/25.
//

import Foundation
protocol NotificationViewModelInterface {
    func fetchNotification() async throws -> NotificationResponse
    var notifications : [NotificationModel]? {get}
}

class NotificationViewModel : NotificationViewModelInterface {
    var networkManager : NetworkManagerProtocol?
    var notifications : [NotificationModel]?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchNotification() async throws -> NotificationResponse {
        guard let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else {throw NetworkManagerError.invalidRequest}
        let url = URLs.notificationUrl(mobileNumber: mobileNumber)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else {throw NetworkManagerError.invalidRequest}
        let header = ["Authorization": "Bearer \(authToken)"]
        guard let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header) else {throw NetworkManagerError.invalidRequest}
        
        return try await withCheckedThrowingContinuation{ continuation in
            networkManager?.request(request, decodeTo: NotificationResponse.self) { result in
                switch result {
                case .success(let response):
                    if response.status{
                        self.notifications = response.data
                    }
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
