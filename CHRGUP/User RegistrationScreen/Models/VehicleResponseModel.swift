//
//  VehicleResponseModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 04/03/25.
//

import Foundation

struct VehicleCatalogResponse: Decodable {
    let success : Bool
    let data : [VehicleTypes]
    let message : String?
}

typealias VehicleTypes = [String : Make]

typealias Make = [String : Model]

typealias Model = [String : [Variant]]

struct Variant: Decodable {
    let variant : String
    let ARAI_range : String
    let claimed_range : String
    let image : String
}
