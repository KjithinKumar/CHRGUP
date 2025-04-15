//
//  StopChargingResponseModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 14/04/25.
//

import Foundation
struct StopChargingResponseModel : Codable {
    let status :Bool
    let message :String?
    let messageId : String?
}

struct StopChargingPayload : Codable {
    let sessionId : String
}

struct StopChargingRequest : Codable {
    let action : String
    let chargerId : String
    let payload : StopChargingPayload
    let sessionId : String
    let sessionReason : String
}
