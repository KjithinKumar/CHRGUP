//
//  ChargerInfoModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 21/03/25.
//

import Foundation
struct ChargerInfo : Codable {
    var status : String?
    let type : String?
    let subType : String?
    let powerOutput : String?
    let id : String?
    let costPerUnit : Cost?
    let name : String?
    let energyConsumptions : String?
    let noOfConnector: Int?
    let connectors: [Connector]?
    let otherDatas: OtherData?
    enum CodingKeys : String, CodingKey {
        case status
        case type
        case subType = "subtype"
        case powerOutput
        case id = "_id"
        case costPerUnit
        case name
        case energyConsumptions
        case noOfConnector
        case connectors
        case otherDatas
    }
}

