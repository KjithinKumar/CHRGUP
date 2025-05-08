//
//  MessageModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 03/05/25.
//

import Foundation
struct MessageResponseModel : Codable{
    let status : Bool
    let message : String?
    let messages : [MessageModel]?
}

struct MessageModel : Codable{
    let id : String
    let ticketId : String
    let senderId : String
    let senderModel : String
    let message : String
    let createdAt : String
    let updatedAt : String?
    
    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case ticketId
        case senderId
        case senderModel
        case message
        case createdAt
        case updatedAt
    }
}
