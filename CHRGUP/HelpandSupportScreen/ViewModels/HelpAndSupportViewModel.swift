//
//  HelpAndSupportViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/03/25.
//

import Foundation
import UIKit

protocol HelpandSupportViewModelDelegate: AnyObject {
    func faqLoaded()
    
}

protocol HelpAndSupportViewModelInterface {
    var faqCategories : [String]? {get}
    func getFAQCategories()
    var fields : [HelpAndSupportDataModel] {get set}
    var expandedDropdownIndex: Int? { get set }
    var categoryOptions : [String]? {get set}
    func getTicketCategories(completion : @escaping (Result<ticketCategoryResponseModel,Error>) -> Void)
    func fetchHistory(completion : @escaping (Result<HistoryResponseModel,Error>)-> Void)
    var history : [HistoryModel]? {get set}
    func createTicket(parameters : [String : String], image: UIImage?,imageFieldName: String,completion : @escaping (Result<createTicketResponseModel ,Error>) -> Void)
}
class HelpAndSupportViewModel: HelpAndSupportViewModelInterface {
    var networkManager : NetworkManagerProtocol?
    weak var delegate : HelpandSupportViewModelDelegate?
    
    init(networkManager: NetworkManagerProtocol, delegate: HelpandSupportViewModelDelegate?) {
        self.networkManager = networkManager
        self.delegate = delegate
    }
    var faqCategories : [String]?
    
    var fields : [HelpAndSupportDataModel] = [HelpAndSupportDataModel.generalFaq(title: AppStrings.HelpandSupport.generalFaqText, image: "chevron.right", type: .faq),
                                              HelpAndSupportDataModel.customerServiceTitle(title: AppStrings.HelpandSupport.customerServiceText, subTitle: AppStrings.HelpandSupport.customerServiceSubText),
                                              HelpAndSupportDataModel.selectCategory(title: AppStrings.HelpandSupport.categoryText, placeHolder: AppStrings.HelpandSupport.categoryPlaceholderText, image: "chevron.down"),
                                              HelpAndSupportDataModel.selectSession(title: AppStrings.HelpandSupport.sessionText, placeHolder: AppStrings.HelpandSupport.sessionPlaceholderText, image: "chevron.down"),
                                              HelpAndSupportDataModel.subject(title: AppStrings.HelpandSupport.subjectText, placeHolder: AppStrings.HelpandSupport.subjectPlaceholderText),
                                              HelpAndSupportDataModel.message(title: AppStrings.HelpandSupport.messageText, placeHolder: AppStrings.HelpandSupport.messagePlaceholderText),
                                              HelpAndSupportDataModel.attachImage]
    var expandedDropdownIndex: Int?
    var categoryOptions : [String]?
    var history : [HistoryModel]?
    
    func getFAQCategories() {
        let url = URLs.faqURl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return}
        let headers = ["Authorization": "Bearer \(authToken)"]
        let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: headers)
        if let request = request {
            networkManager?.request(request, decodeTo: faqCategoryResponse.self, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    let responseData = response.data
                    self.faqCategories = responseData
                    self.delegate?.faqLoaded()
                case .failure(let error):
                    debugPrint(error)
                }
            })
        }
    }
    
    func getTicketCategories(completion : @escaping (Result<ticketCategoryResponseModel,Error>) -> Void) {
        let url = URLs.ticketCategoryUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return}
        let headers = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: headers){
            networkManager?.request(request, decodeTo: ticketCategoryResponseModel.self) { [weak self] result in
                switch result {
                case .success(let response):
                    if response.success {
                        self?.categoryOptions = response.data ?? []
                    }
                case .failure(let error):
                    print(error)
                }
                completion(result)
            }
        }
    }
    func fetchHistory(completion : @escaping (Result<HistoryResponseModel,Error>)-> Void) {
        guard let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else {return}
        let url = URLs.gethistoryUrl(mobileNumber: mobileNumber)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else {return}
        let header = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: HistoryResponseModel.self) { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .success(let response):
                    if response.status{
                        if let data = response.data{
                            self.history = data
                        }
                    }
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            
            }
        }
    }
    func createTicket(parameters : [String : String], image: UIImage?,imageFieldName: String = "screenshots",completion : @escaping (Result<createTicketResponseModel ,Error>) -> Void){
        let url = URLs.createTicketUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else {return}
        let boundary = "Boundary-\(UUID().uuidString)"
        let header = ["Authorization": "Bearer \(authToken)",
                      "Content-Type" : "multipart/form-data; boundary=\(boundary)"
        ]
        var body = Data()
        
        for (key, value) in parameters {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        if let imageData = image?.jpegData(compressionQuality: 0.8) {
            let filename = "upload.jpg"
            let mimeType = "image/jpeg"
            
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(imageFieldName)\"; filename=\"\(filename)\"\r\n")
            body.appendString("Content-Type: \(mimeType)\r\n\r\n")
            body.append(imageData)
            body.appendString("\r\n")
        }
        
        body.appendString("--\(boundary)--\r\n")
        var request = networkManager?.createRequest(urlString: url, method: .post, body: nil, encoding: .json, headers: header)
        request?.httpBody = body
        if let request = request {
            networkManager?.request(request, decodeTo: createTicketResponseModel.self) { [weak self] result in
                guard let _ = self else {return}
                completion(result)
            }
        }
    }
}
extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
