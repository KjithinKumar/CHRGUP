//
//  ChargerLocationResponse.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 21/03/25.
//

import Foundation
struct ChargerLocationResponse : Decodable{
    let success: Bool
    let data : [ChargerLocation]?
    let message: String?
    let sessionInfo : SessionData?
}

struct ChargerLocation : Codable{
    let id: String
    let locationName: String
    let locationType: String
    let state: String
    let city: String
    let address: String
    let direction: Direction
    let salesManager: Person?
    let dealer: Person?
    let facilities: [Facility]?
    let status: String
    let chargerInfo: [ChargerInfo]
    let workingHours: String
    let workingDays: String
    let locationImage: [String]
    let createdAt: String
    let updatedAt: String?
    var isFromSharedPreferences: Bool?
    let version: Int
    var distance: Double?
    var modDistance: String?
    var modpointsAvailable : Int?
    var modLocationAvailble : Bool?
    let freePaid: FreePaid
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case locationName
        case locationType
        case state
        case city
        case address
        case direction
        case salesManager
        case dealer
        case facilities
        case status
        case chargerInfo
        case workingHours
        case workingDays
        case locationImage
        case createdAt
        case updatedAt
        case isFromSharedPreferences
        case version = "__v"
        case distance
        case freePaid = "freepaid"
    }
}

