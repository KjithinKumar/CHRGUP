//
//  ReviewResponseModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 10/04/25.
//

import Foundation

struct ReviewResponseModel : Codable {
    let success : Bool
    let message : String?
    let data : ReviewData?
}
struct ReviewData : Codable {
    let id : String
    let user : String
    let location : String
    let charging_exp : Int
    let charging_location : Int
    let review : String
    let createdAt : String
    let updatedAt : String
    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case user,location,charging_exp,charging_location,review,createdAt,updatedAt
    }
}
