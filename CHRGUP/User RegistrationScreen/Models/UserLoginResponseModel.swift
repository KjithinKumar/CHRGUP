//
//  UserLoginResponseModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 04/03/25.
//

import Foundation
struct UserLoginResponseModel: Decodable {
    let success: Bool
    let message: String?
    let data: UserProfile?
    let token: String?
    let sessionId: String?
    let startTime: String?
    let status: String?
    let chargerId: String?
    let locationId: String?
}

