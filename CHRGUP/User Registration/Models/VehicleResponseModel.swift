//
//  VehicleResponseModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 04/03/25.
//

import Foundation
//struct VehicleResponseModel: Codable {
//    let category: String
//    let manufacturer: String
//    let model: String
//    let variant: String
//    let ARAI_range: String
//    let claimed_range: String
//    let image: String
//}


struct VehicleResponse: Decodable {
    let success : Bool
    let data : [VehicleType]
}

typealias VehicleTypes = [String : VehicleType]

struct VehicleType: Decodable {
    let threewheeler : [String: Make]
    let twowheeler : [String: Make]
    
    enum CodingKeys: String, CodingKey {
        case threewheeler = "3-Wheeler"
        case twowheeler = "2-Wheeler"
    }
}

typealias Make = [String : [Variant]]

struct Variant: Decodable {
    let variant : String
    let ARAI_range : String
    let claimed_range : String
    let image : String
}
