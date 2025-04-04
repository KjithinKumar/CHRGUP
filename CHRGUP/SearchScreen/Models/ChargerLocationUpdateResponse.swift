//
//  ChargerLocationUpdateResponse.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 03/04/25.
//

import Foundation

struct ChargerLocationUpdateResopnse : Decodable{
    let success: Bool
    let data : ChargerLocation?
    let message: String?
}
