//
//  PersonModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 21/03/25.
//

import Foundation
struct Person : Codable{
    let name : String
    let phoneNumber : String
    let email : String
    let id : String
    enum CodingKeys : String, CodingKey {
        case name
        case phoneNumber
        case email
        case id = "_id"
    }
}
