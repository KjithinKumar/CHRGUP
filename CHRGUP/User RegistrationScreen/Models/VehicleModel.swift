//
//  UserVehicleModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 06/03/25.
//

import Foundation

struct VehicleModel : Codable{
    var type: String
    var make: String        // Brand of the vehicle
    var model: String       // Model name of the vehicle
    var variant: String     // Variant or trim level of the vehicle
    var vehicleReg: String  // Registration number of the vehicle
    var range: String       // Driving range of the vehicle (e.g., in km or miles)
    var id: String?          // Unique ID assigned to the vehicle
    var vehicleImg: String  // URL of the vehicle's image

    enum CodingKeys: String, CodingKey {
        case type, make, model, variant, range
        case vehicleReg = "vehicle_reg"
        case id = "_id"
        case vehicleImg = "vehicle_img"
    }
}

struct UserVehicleResponse : Codable{
    var success: Bool
    var data: [VehicleModel]?
    var message : String?
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case data = "data"
        case message = "message"
    }
}

struct newVehicleResponse : Codable{
    var success: Bool
    var data : VehicleModel?
    var message : String?
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case data = "data"
        case message = "message"
    }
}

