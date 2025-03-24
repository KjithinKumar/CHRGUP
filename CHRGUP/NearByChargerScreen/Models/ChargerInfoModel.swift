//
//  ChargerInfoModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 21/03/25.
//

import Foundation
struct ChargerInfo : Codable {
    let status : String?
    let type : String?
    let subType : String?
    let powerOutput : String?
    let id : String?
    enum CodingKeys : String, CodingKey {
        case status
        case type
        case subType
        case powerOutput
        case id = "_id"
    }
}
