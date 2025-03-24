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
