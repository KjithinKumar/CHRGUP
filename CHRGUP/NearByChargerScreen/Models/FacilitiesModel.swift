//
//  FacilitiesModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 21/03/25.
//

import Foundation

struct Facility : Codable{
    let name : String
    let icon : String
    let id : String
    enum CodingKeys : String, CodingKey {
        case name
        case icon
        case id = "_id"
    }
}
