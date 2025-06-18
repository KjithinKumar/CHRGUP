//
//  ReservationViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 02/06/25.
//

import Foundation
protocol ReservationViewModelInterface {
    func fetchReservations() async throws -> ReservationResponse
    var filteredReservations: [Reservation] { get set }
    var onDataChanged: (() -> Void)? { get set }
    var currentFilter: ReservationFilter { get set }
    func cancelReservation(at index: Int) async throws -> CancelReservationResponse
}

class ReservationViewModel: ReservationViewModelInterface {
    var networkManager : NetworkManagerProtocol?
    var allReservations: [Reservation] = []
    var filteredReservations: [Reservation] = []
    var onDataChanged: (() -> Void)?
    var currentFilter: ReservationFilter = .all {
        didSet {
            applyFilter()
        }
    }
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchReservations() async throws -> ReservationResponse{
        let url = URLs.reservationsByUserUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { throw NetworkManagerError.invalidRequest }
        guard let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else { throw NetworkManagerError.invalidRequest }
        let header = ["Authorization": "Bearer \(authToken)"]
        let requestBody : [String : Any] = ["userPhone" : mobileNumber,
                                            "timezone" : AppConstants.timeZone]
        guard let request = networkManager?.createRequest(urlString: url, method: .post, body: requestBody, encoding: .json, headers: header)else {throw NetworkManagerError.invalidRequest}
        
        return try await withCheckedThrowingContinuation { continuation in
            networkManager?.request(request, decodeTo: ReservationResponse.self) { result in
                switch result {
                case .success(let value):
                    if let data = value.data{
                        self.allReservations = data
                        self.applyFilter()
                    }
                    continuation.resume(returning: value)
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    func applyFilter() {
        switch currentFilter {
        case .all:
            filteredReservations = allReservations
        case .completed:
            filteredReservations = allReservations.filter { $0.status == "Completed" }
        case .failed:
            filteredReservations = allReservations.filter { $0.status == "Cancelled" }
        case .reserved:
            filteredReservations = allReservations.filter { $0.status == "Reserved" }
        }
        onDataChanged?()
    }
    func cancelReservation(at index: Int) async throws -> CancelReservationResponse{
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { throw NetworkManagerError.invalidRequest }
        guard index < filteredReservations.count else {throw NetworkManagerError.invalidRequest}
        let reservation = filteredReservations[index]
        let chargerId = reservation.chargerId
        let url = URLs.cancelReservationUrl(reservationId: reservation.reservationId)
        let header = ["Authorization": "Bearer \(authToken)"]
        let body : [String : Any] = ["chargerId": chargerId]
        guard let request = networkManager?.createRequest(urlString: url, method: .patch, body: body, encoding: .json, headers: header)else {throw NetworkManagerError.invalidRequest}
        return try await withCheckedThrowingContinuation { continuation in
            networkManager?.request(request, decodeTo: CancelReservationResponse.self) { result in
                switch result {
                case .success(let value):
                    if let actualIndex = self.allReservations.firstIndex(where: { $0.id == reservation.id }) {
                        self.allReservations[actualIndex].status = "Cancelled"
                        self.applyFilter()
                    }
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
