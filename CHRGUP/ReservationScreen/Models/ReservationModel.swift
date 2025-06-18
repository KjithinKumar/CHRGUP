//
//  ReservationModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 02/06/25.
//

import Foundation
struct ReservationResponse: Codable {
    let status: Bool
    let data: [Reservation]?
    let message: String
}

struct Reservation: Codable {
    let id: String
    let reservationId: Int
    let idTag: String
    let chargerId: String
    let connectorId: Int?
    let startTime: String
    let endTime: String
    var status: String
    let createdBy: String?
    let createdAt: String?
    let updatedAt: String?
    let v: Int?
    let startTimeIST: String
    let endTimeIST: String
    let formattedDuration: String?
    let locationName: String
    let cancelledBy: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case reservationId, idTag, chargerId, connectorId
        case startTime, endTime, status, createdBy, createdAt, updatedAt
        case v = "__v"
        case startTimeIST, endTimeIST, formattedDuration, locationName, cancelledBy
    }
}
struct CancelReservationResponse : Codable {
    let status : Bool
    let message : String
    let reservationId : String?
}
enum ReservationFilter {
    case all
    case completed
    case failed
    case reserved
}
