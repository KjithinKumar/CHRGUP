//
//  WalletViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/09/25.
//

import Foundation
protocol WalletViewModelInterface{
    func fetchWalletStatus(transaction : Bool,page : Int,limit : Int,refund : Bool) async throws -> WalletStatusModel?
    func createOder(amount : Int,currency : String,completion : @escaping (Result<PaymentDetails, Error>) -> Void)
    func fetchPaymentDetails(paymentId : String,completion : @escaping(Result<PaymentDetails, Error>) -> Void)
    func capturePayment(paymentId: String, amount : Int,completion : @escaping(Result<PaymentDetails,Error>) -> Void)
    func createPaymentOnServer(userId: String,details : PaymentDetails, completion : @escaping(Result<PaymentDetailsResponse,Error>)->Void)
    var isLoading : Bool {get set}
    var currentPage : Int {get set}
    var totalPage : Int {get set}
    var walletdata : WalletdataModel? {get}
    var onDataChanged: (() -> Void)? {get set}
    var filteredTransactions : [transactionModel]? {get}
    var currentFilter : TransactionFilter {get set}
}

class WalletViewModel : WalletViewModelInterface{
    var networkManager : NetworkManagerProtocol?
    var isLoading = false
    var currentPage = 1
    var totalPage = 1
    var walletdata : WalletdataModel?
    var filteredTransactions : [transactionModel]?
    var onDataChanged: (() -> Void)?
    var currentFilter : TransactionFilter = .all{
        didSet{
            applyFilter()
        }
    }
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    func applyFilter(){
        guard let allTransactions = walletdata?.transactions else { return }
        
        switch currentFilter {
        case .all:
            filteredTransactions = allTransactions
        case .added:
            filteredTransactions = allTransactions.filter { $0.type.contains("credit") }
        case .charged:
            filteredTransactions = allTransactions.filter { $0.type.contains("debit") }
        case .refund:
            filteredTransactions = allTransactions.filter({ $0.type.contains("refund") })
        }
        onDataChanged?()
    }
    func fetchWalletStatus(transaction : Bool,page : Int,limit : Int,refund : Bool) async throws -> WalletStatusModel?{
        guard !isLoading else { return nil }
        guard currentPage <= totalPage else { return nil }
        isLoading = true
        guard let authToken = UserDefaultManager.shared.getJWTToken() else {
            isLoading = false
            throw NetworkManagerError.invalidRequest
        }
        guard let userId  = UserDefaultManager.shared.getUserProfile()?.id else {
            isLoading = false
            throw NetworkManagerError.invalidRequest}
        let url = URLs.walletdetailsUrl(userId: userId, transaction: transaction,page: page,limit: limit, refund: refund)
        let header = ["Authorization": "Bearer \(authToken)"]
        guard let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header)else {
            isLoading = false
            throw NetworkManagerError.invalidRequest}
        return try await withCheckedThrowingContinuation { continuation in
            networkManager?.request(request, decodeTo: WalletStatusModel.self) { [weak self] result in
                guard let self = self else {return}
                
                switch result {
                case .success(let value):
                    self.currentPage = value.data.currentPage ?? 1
                    self.totalPage = value.data.totalPages ?? 1
                    if self.currentPage == 1{
                        self.walletdata = value.data
                    }else{
                        self.walletdata?.transactions?.append(contentsOf: value.data.transactions ?? [])
                    }
                    self.applyFilter()
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
                self.isLoading = false
            }
        }
    }
    //Create the order for payment.
    func createOder(amount : Int,currency : String,completion : @escaping (Result<PaymentDetails, Error>) -> Void){
        let url = URLs.razorPayOrderUrl
        let key = AppIdentifications.RazorPay.key
        let secret = AppIdentifications.RazorPay.secret
        let loginString = "\(key):\(secret)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let header = ["Authorization":"Basic \(base64LoginString)"]
        let body = [
            "amount": amount,
            "currency": currency
        ] as [String : Any]
        
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header ){
            networkManager?.request(request, decodeTo: PaymentDetails.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
    //Fetch the payment details from razor pay
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
    //Capture the payment in razorpay
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
    //Post the payment details to the server
    func createPaymentOnServer(userId: String,details : PaymentDetails, completion : @escaping(Result<PaymentDetailsResponse,Error>)->Void){
        let url = URLs.serverPaymentUrl
        var body = details
        body.userId = userId
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        debugPrint(body)
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body.toDictionary(), encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: PaymentDetailsResponse.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
}
