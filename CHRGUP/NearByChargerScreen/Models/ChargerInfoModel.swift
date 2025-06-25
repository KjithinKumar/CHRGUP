//
//  ChargerInfoModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 21/03/25.
//

import Foundation
struct ChargerInfo : Codable {
    var status : String?
    var type : String?
    var subType : String?
    var powerOutput : String?
    let id : String?
    let costPerUnit : Cost?
    var name : String?
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

