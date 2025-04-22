//
//  ReceiptViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/04/25.
//

import Foundation
protocol ReceiptViewModelInterface{
    func fetchReceiptData(completeion: @escaping (Result<ReceiptResponseModel, Error>) -> Void)
    func assembleReceipt(from models: [ReceiptModel]) -> ReceiptDisplayModel
    var receiptList : [ReceiptListModel]? { get }
    var receiptData : ReceiptDisplayModel? { get }
    func createOder(amount : Int,completion : @escaping (Result<PaymentDetails, Error>) -> Void)
    func fetchPaymentDetails(paymentId : String,completion : @escaping(Result<PaymentDetails, Error>) -> Void)
    func capturePayment(paymentId: String, amount : Int,completion : @escaping(Result<PaymentDetails,Error>) -> Void)
    func createPaymentOnServer(sessionId: String,details : PaymentDetails, completion : @escaping(Result<PaymentDetailsResponse,Error>)->Void)
    func checkReviewforLocation(completion : @escaping(Result<ReviewExistResponse,Error>)->Void)
}
class ReceiptViewModel: ReceiptViewModelInterface {
    var networkManager: NetworkManagerProtocol?
    var receiptList : [ReceiptListModel]? = [ReceiptListModel]()
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    var receiptData : ReceiptDisplayModel?
    func fetchReceiptData(completeion: @escaping (Result<ReceiptResponseModel, Error>) -> Void) {
        let url = URLs.getReceiptUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        guard let sessionId = UserDefaultManager.shared.getSessionId() else { return }
        let body : [String : Any] = ["sessionId" : sessionId]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: ReceiptResponseModel.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.receiptData = assembleReceipt(from: response.data)
                    completeion(.success(response))
                case .failure(let error):
                    completeion(.failure(error))
                }
            }
        }
    }
    func assembleReceipt(from models: [ReceiptModel]) -> ReceiptDisplayModel {
        var displayModel = ReceiptDisplayModel()
        
        for model in models {
            if let headerArray = model.header, !headerArray.isEmpty {
                displayModel.header = headerModel.merged(from: headerArray)
                if let header = displayModel.header{
                    receiptList?.append(.header(header))
                }
            }
            
            if let sessionDetails = model.sessionDetails {
                displayModel.sessionDetails = sessionDetails
                receiptList?.append(.sessionDetails(sessionDetails))
            }
            
            if let energyDetails = model.energyDetails {
                displayModel.energyDetails = energyDetails
                receiptList?.append(.energyDetails(energyDetails))
                receiptList?.append(.solidDivider(.dotted))
            }
            
            
            if let subtotalDetails = model.subtotalDetails {
                displayModel.subtotalDetails = subtotalDetails
                receiptList?.append(.subtotalDetails(subtotalDetails))
                receiptList?.append(.solidDivider(.solid))
            }
            
            if let sessionCharges = model.sessionCharges {
                displayModel.sessionCharges = sessionCharges
                receiptList?.append(.sessionCharges(sessionCharges))
                receiptList?.append(.solidDivider(.dotted))
            }
            
            if let taxDetails = model.taxDetails {
                displayModel.taxDetails = taxDetails
                receiptList?.append(.taxDetails(taxDetails))
                receiptList?.append(.solidDivider(.dotted))
            }
            
            if let grandTotal = model.grandTotal {
                displayModel.grandTotal = grandTotal
                receiptList?.append(.grandTotal(value : grandTotal))
            }
        }
        return displayModel
    }
    
    func createOder(amount : Int,completion : @escaping (Result<PaymentDetails, Error>) -> Void){
        let url = URLs.razorPayOrderUrl
        let key = AppIdentifications.RazorPay.key
        let secret = AppIdentifications.RazorPay.secret
        let loginString = "\(key):\(secret)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let header = ["Authorization":"Basic \(base64LoginString)"]
        let body = [
            "amount": amount,
            "currency": "INR"
        ] as [String : Any]
        
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header ){
            networkManager?.request(request, decodeTo: PaymentDetails.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
    func fetchPaymentDetails(paymentId : String,completion : @escaping(Result<PaymentDetails, Error>) -> Void){
        let url = URLs.razorPayPaymentDetailUrl(paymentId: paymentId)
        let key = AppIdentifications.RazorPay.key
        let secret = AppIdentifications.RazorPay.secret
        let loginString = "\(key):\(secret)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let header = ["Authorization":"Basic \(base64LoginString)"]
        if let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: PaymentDetails.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
    func capturePayment(paymentId: String, amount : Int,completion : @escaping(Result<PaymentDetails,Error>) -> Void){
        let url = URLs.capturePaymentUrl(paymentId: paymentId)
        let key = AppIdentifications.RazorPay.key
        let secret = AppIdentifications.RazorPay.secret
        let loginString = "\(key):\(secret)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let header = ["Authorization":"Basic \(base64LoginString)"]
        let body = [
            "amount": amount,
            "currency": "INR"
        ] as [String : Any]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: PaymentDetails.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
    func createPaymentOnServer(sessionId: String,details : PaymentDetails, completion : @escaping(Result<PaymentDetailsResponse,Error>)->Void){
        let url = URLs.serverPaymentUrl
        var body = details
        body.sessionId = sessionId
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body.toDictionary(), encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: PaymentDetailsResponse.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
    func checkReviewforLocation(completion : @escaping(Result<ReviewExistResponse,Error>)->Void){
        guard let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else { return }
        guard let chargerLocationId = UserDefaultManager.shared.getScannedLocationId() else { return }
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        let url = URLs.checkReviewExistUrl(mobileNumber: mobileNumber, locationId: chargerLocationId)
        if let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: ReviewExistResponse.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
}
