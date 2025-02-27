//
//  VersionResponseModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import Foundation
struct VersionResponseModel: Decodable {
    let status: Bool
    let force: Bool
    let iPhoneUrl: String?
    
    enum CodingKeys : String,CodingKey{
        case status = "status"
        case force = "force"
        case iPhoneUrl = "iphone_url"
    }
}
