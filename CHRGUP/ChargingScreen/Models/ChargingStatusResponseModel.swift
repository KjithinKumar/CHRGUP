//
//  ChargingStatusResponseModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 12/04/25.
//

import Foundation

struct ChargingStatusResponseModel: Decodable {
    let status : Bool
    let message : String?
    let data : ChargingStatusModel?
}

struct ChargingStatusModel: Decodable {
    let firstMeterValue : Double
    let lastMeterValue : Double
    let meterValueDifference : String
    let status : String?
    let reason : String?
    let startTimeIST : String?
    let costPerUnit : Cost?
}

struct RemoteNotificationsResponse : Decodable {
    let status : Bool
    let message : String
}
