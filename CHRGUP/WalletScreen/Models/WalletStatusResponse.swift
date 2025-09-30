//
//  WalletStatusResponse.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/09/25.
//

import Foundation
struct WalletStatusResponse : Codable{
    let status : Bool
    let message : String?
    let walletActivated : Bool
    let walletBalance : Bool
    
    enum CodingKeys: String, CodingKey{
        case status
        case message
        case walletActivated = "wallet_activated"
        case walletBalance = "wallet_balance"
    }
}
