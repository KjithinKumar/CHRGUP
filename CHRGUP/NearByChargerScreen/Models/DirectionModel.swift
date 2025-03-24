//
//  DirectionModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 21/03/25.
//

import Foundation

struct Direction : Codable{
    let latitude : Double
    let longitude : Double
    let id : String
    enum CodingKeys : String, CodingKey {
        case latitude
        case longitude
        case id = "_id"
    }
}
