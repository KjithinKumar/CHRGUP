//
//  WalletStatus.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/09/25.
//

import Foundation

struct WalletStatusModel : Codable{
    var status : Bool
    var message : String?
    var data : WalletdataModel
}

struct WalletdataModel : Codable{
    var balance : Int
    var transactions : [transactionModel]?
    var currentPage : Int?
    var totalPages : Int?
    var totalItems : Int?
}

struct transactionModel : Codable{
    var transactionId : String
    var type : String
    var amount : Int
    var timestamp : String
    var description : String
    var isRefund : Bool
    enum CodingKeys : String,CodingKey{
        case transactionId,type,amount,timestamp,description
        case isRefund = "is_refund"
    }
}

enum WalletCellType {
    case transaction(transactionModel)
    case loading
    case empty
}

enum TransactionFilter{
    case all
    case added
    case charged
    case refund
}
