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
//        let createdAt: String
//        let updatedAt: String
//        let category: String

        // Custom CodingKeys to map JSON keys
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case question
            case answer
//            case createdAt
//            case updatedAt
//            case category
        }

}

struct faqResponse : Codable{
    let success : Bool
    let data : [faqData]
    
    
}
