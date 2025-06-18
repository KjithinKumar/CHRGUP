//
//  ReservationModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 02/06/25.
//

import Foundation
struct ReservationResponseModel : Codable{
    let status : Bool
    let message : String
    let reservationId : Int?
}
