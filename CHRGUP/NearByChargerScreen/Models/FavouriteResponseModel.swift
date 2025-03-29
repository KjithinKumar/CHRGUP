//
//  FavouriteResponseModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/03/25.
//

import Foundation
struct FavouriteResponseModel: Decodable {
    let status: Bool
    let message: String?
    let data: UserProfile?
}

struct GetFavouriteResponseModel: Decodable {
    let status: Bool
    let message: String?
    let data: [ChargerLocation]
}
