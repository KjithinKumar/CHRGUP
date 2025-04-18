//
//  ReceiptModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/04/25.
//

import Foundation
struct ReceiptResponseModel : Decodable {
    let status : Bool
    let data : [ReceiptModel]
    let message : String?
}

struct ReceiptModel: Decodable {
    let header: [headerModel]?
    let sessionDetails: sessionDetailsModel?
    let energyDetails: energyDetailsModel?
    let subtotalDetails: subtotalDetailsModel?
    let sessionCharges: SessionChargesModel?
    let taxDetails: taxDetailsModel?
    let grandTotal: String?

    enum CodingKeys: String, CodingKey {
        case header
        case sessionDetails = "session-details"
        case energyDetails = "energy-details"
        case subtotalDetails = "subtotal details"
        case sessionCharges = "session details"
        case taxDetails = "tax details"
        case grandTotal = "Grand Total"
    }
}
//typealias headerModel = [[String: String]]
typealias sessionDetailsModel = [[String: String]]
typealias energyDetailsModel = [[String]]
typealias subtotalDetailsModel = [[String: String]]
typealias SessionChargesModel = [[String: String]]
typealias taxDetailsModel = [[String: String]]

struct headerModel : Decodable{
    var type : String?
    var powerOutput : String?
    var chargerLocation : String?
    var createdAt : String?
    var chargerId : String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case powerOutput = "powerOutput"
        case chargerLocation = "Charger location"
        case createdAt = "createdAt"
        case chargerId = "Charger ID"
    }
}
struct ReceiptDisplayModel {
    var header: headerModel?
    var sessionDetails: sessionDetailsModel?
    var energyDetails: energyDetailsModel?
    var subtotalDetails: subtotalDetailsModel?
    var sessionCharges: SessionChargesModel?
    var taxDetails: taxDetailsModel?
    var grandTotal: String?
}
extension headerModel {
    static func merged(from array: [headerModel]) -> headerModel {
        var merged = headerModel(type: nil, powerOutput: nil, chargerLocation: nil, createdAt: nil, chargerId: nil)

        for item in array {
            if let type = item.type {
                merged.type = type
            }
            if let powerOutput = item.powerOutput {
                merged.powerOutput = powerOutput
            }
            if let chargerLocation = item.chargerLocation {
                merged.chargerLocation = chargerLocation
            }
            if let createdAt = item.createdAt {
                merged.createdAt = createdAt
            }
            if let chargerId = item.chargerId {
                merged.chargerId = chargerId
            }
        }
        return merged
    }
}

enum ReceiptListModel{
    case header (headerModel)
    case sessionDetails (sessionDetailsModel)
    case energyDetails (energyDetailsModel)
    case subtotalDetails (subtotalDetailsModel)
    case sessionCharges (SessionChargesModel)
    case taxDetails (taxDetailsModel)
    case grandTotal (value : String)
    case solidDivider (Divider)
}
enum Divider {
    case solid
    case dotted
}
