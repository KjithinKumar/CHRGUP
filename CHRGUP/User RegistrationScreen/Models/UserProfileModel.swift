//
//  UserProfileModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 04/03/25.
//

import Foundation
struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var userVehicle: [VehicleModel]
    var email: String
    var gender: String
    var dob: String
    var city: String
    var state: String
    var phoneNumber: String
    var profilePic: String
    var userFavouriteChargerLocations: [String]?

    enum CodingKeys: String, CodingKey {
        case firstName, lastName, email, gender, dob, city, state, phoneNumber, profilePic
        case userVehicle = "user_vehicle"
        case userFavouriteChargerLocations = "user_favourite_charger_locations"
    }
}
extension Encodable {
    func toDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return jsonObject
        } catch {
            print("Error encoding object: \(error)")
            return nil
        }
    }
}
