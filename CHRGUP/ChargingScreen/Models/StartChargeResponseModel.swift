//
//  StartChargeResponseModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/04/25.
//

import Foundation
struct StartChargeResponseModel : Decodable {
    var status: Bool
    var message: String?
    var messageId : String?
    var sessionId : String?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case messageId = "messageId"
        case sessionId = "sessionId"
    }
}
struct StartChargingRequest: Codable {
    let action: String
    let chargerId: String
    let vehicleId: String
    let payload: payload
    let sessionReason: String
}

struct payload: Codable {
    let idTag: String
    let connectorId : Int
}
