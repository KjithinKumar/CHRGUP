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
    var data : StartData?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case messageId = "messageId"
        case sessionId = "sessionId"
        case data = "data"
    }
}
struct StartData: Decodable{
    var addMoney : Int?
    
    enum CodingKeys : String, CodingKey{
        case addMoney = "add_money"
    }
}
struct StartChargingRequest: Codable {
    let action: String
    let chargerId: String
    let vehicleId: String
    let payload: StartChargingpayload
    let sessionReason: String
}

struct StartChargingpayload: Codable {
    let idTag: String
    let connectorId : Int
}
