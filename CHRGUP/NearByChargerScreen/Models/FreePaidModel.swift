//
//  FreePaidModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 21/03/25.
//

import Foundation
struct FreePaid : Codable {
    let parking : Bool
    let charging : Bool
    let id : String
    enum CodingKeys : String, CodingKey {
        case parking
        case charging
        case id = "_id"
    }
}
