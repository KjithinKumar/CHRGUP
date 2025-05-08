//
//  PaymentDetailsModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 18/04/25.
//

import Foundation
struct PaymentDetails: Codable {
    let id: String?
    let entity: String?
    let amount: Int?
    let currency: String?
    let status: String?
    let orderId: String?
    let invoiceId: String?
    let international: Bool?
    let method: String?
    let amountRefunded: Int?
    let refundStatus: String?
    let captured: Bool?
    let description: String?
    let cardId: String?
    let bank: String?
    let wallet: String?
    let vpa: String?
    let email: String?
    let contact: String?
    let fee: Int?
    let tax: Int?
    let errorCode: String?
    let errorDescription: String?
    let errorSource: String?
    let errorStep: String?
    let errorReason: String?
    let createdAt: Int?
    var sessionId : String?

    enum CodingKeys: String, CodingKey {
        case id, entity, amount, currency, status
        case orderId = "order_id"
        case invoiceId = "invoice_id"
        case international, method
        case amountRefunded = "amount_refunded"
        case refundStatus = "refund_status"
        case captured, description
        case cardId = "card_id"
        case bank, wallet, vpa, email, contact, fee, tax,sessionId
        case errorCode = "error_code"
        case errorDescription = "error_description"
        case errorSource = "error_source"
        case errorStep = "error_step"
        case errorReason = "error_reason"
        case createdAt = "created_at"
    }
}
struct PaymentDetailsResponse : Decodable{
    let status : Bool
    let message : String?
    let data : PaymentDetails?
}

struct PaymentStatusResponse : Decodable{
    let status : Bool
    let message : String?
}
