//
//  NotificationModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/07/25.
//

import Foundation

struct NotificationResponse: Codable {
    let status : Bool
    let message : String
    let data : [NotificationModel]?
}

struct NotificationModel : Codable {
    let id : String
    let title : String
    let description : String
    let status : String
    let createdAt : String
    let updatedAt : String
    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case title
        case description
        case status
        case createdAt
        case updatedAt
    }
}
