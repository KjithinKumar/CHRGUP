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
}
