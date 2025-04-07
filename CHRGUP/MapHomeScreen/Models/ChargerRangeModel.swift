//
//  ChargerRangeModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 04/04/25.
//

import Foundation

struct ChargerRangeresponse: Decodable {
    let success : Bool
    let data : [ChargerRangeModel]?
    let message : String?
}

struct ChargerRangeModel: Decodable {
    let id : String
    let direction : Direction?
    let chargerInfo : [ChargerInfo]?
    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case direction
        case chargerInfo
    }
}
