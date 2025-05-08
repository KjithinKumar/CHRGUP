//
//  HelpAndSupportModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/03/25.
//

import Foundation

enum HelpAndSupportType{
    case faq
    case contactUs
}

enum HelpAndSupportDataModel{
    case generalFaq(title : String,image : String, type : HelpAndSupportType)
    case customerServiceTitle(title : String, subTitle : String)
    case selectCategory(title : String,placeHolder : String, image : String)
    case selectSession(title : String,placeHolder : String, image : String)
    case subject(title : String,placeHolder : String)
    case message(title : String,placeHolder : String)
    case attachImage
    case dropdownOption(title: String)
    case sessionDropdownOption(history: HistoryModel)
}

struct HelpAndSupportModel{
    let title: String
    let image : String
    let type : HelpAndSupportType
}


struct faqCategoryResponse : Codable{
    let success : Bool
    let data : [String]
}

struct faqData : Codable{
        let id: String
        let question: String
        let answer: String
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case question
            case answer
        }

}

struct faqResponse : Codable{
    let success : Bool
    let data : [faqData]
}

struct ticketCategoryResponseModel : Codable{
    let success : Bool
    let data : [String]?
    let message : String?
}

struct createTicketResponseModel : Codable{
    let status : Bool
    let message : String?
    let ticket : TicketModel?
}

struct TicketModel : Codable{
    var title : String
    var description : String
    var category : String
    var status: String
    var priority : String
    var createdBy : String
    var screenshots : [String]?
    var id : String
    var createdAt : String
    var updatedAt : String
    var v: Int
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case category
        case status
        case priority
        case createdBy
        case screenshots
        case id = "_id"
        case createdAt
        case updatedAt
        case v = "__v"
    }
}
