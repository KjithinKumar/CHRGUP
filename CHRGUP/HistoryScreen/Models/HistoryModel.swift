//
//  HistoryModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/04/25.
//

import Foundation
struct HistoryResponseModel : Decodable {
    let status: Bool
    let message: String?
    let data: [HistoryModel]?
}

struct HistoryModel: Decodable {
    let sessionId: String
    let locationName: String
    let address: String
    let createdAt: String
    let status: String
    let chargerName: String
    let transactionId: String?
    let energyConsumed: String
    let chargerType: String
    let powerOutput: String
    let chargeTime: String
    let vehicle: String
    let paymentMethod: String?
    let paymentAmount: String?
    let paymentStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case sessionId
        case locationName
        case address
        case createdAt
        case status
        case chargerName
        case transactionId
        case energyConsumed = "EnergyConsumed"
        case chargerType
        case powerOutput
        case chargeTime
        case vehicle
        case paymentMethod
        case paymentAmount
        case paymentStatus
    }
}
enum ChargerFilter: String {
    case all = "All"
    case ac = "AC"
    case dc = "DC"
}
