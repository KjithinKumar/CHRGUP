//
//  ChargerNameResponse.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 08/04/25.
//

import Foundation

struct ChargerNameResponse: Decodable {
    let status: Bool
    let data : ChargerLocationData?
    let message: String?
}
struct Location : Codable{
    let locationId : String?
    let locationName: String?
    let locationType: String?
    let freePaid: FreePaid?
    
    enum CodingKeys: String, CodingKey {
        case locationName,locationId
        case locationType
        case freePaid = "freepaid"
    }
}
struct ChargerLocationData : Codable{
    let location : Location?
    let salesManager: Person?
    let dealer: Person?
    let facilities: [Facility]?
    let status: String?
    let chargerInfo: ChargerInfo?
    let workingHours: String?
    let workingDays: String?
    let locationImage: [String]?
    let createdAt: String?
    let updatedAt: String?
    var isFromSharedPreferences: Bool?
    let version: Int?
    var distance: Double?
    var modDistance: String?
    var modpointsAvailable : Int?
    var modLocationAvailble : Bool?
    
    
    enum CodingKeys: String, CodingKey {
        case location
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
    }
}
