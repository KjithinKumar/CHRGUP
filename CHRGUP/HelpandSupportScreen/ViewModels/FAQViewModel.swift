//
//  FAQViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/03/25.
//

import Foundation
protocol FAQViewModelInterface {
    var FAQs : [faqData]? { get }
    func loadFAQs(category : String)
    
}
protocol FAQViewModelDelegate: AnyObject {
    func loadedFAQs()
}
class FAQViewModel : FAQViewModelInterface{
    weak var delegate: FAQViewModelDelegate?
    var networkManager: NetworkManagerProtocol?
    
    init(delegate: FAQViewModelDelegate, networkManager: NetworkManagerProtocol) {
        self.delegate = delegate
        self.networkManager = networkManager
    }
    
    var FAQs : [faqData]?
    
    func loadFAQs(category : String) {
        let url = URLs.faqCatergoryUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return}
        let headers = ["Authorization": "Bearer \(authToken)"]
        let body = ["category" : "\(category)"]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: headers){
            networkManager?.request(request, decodeTo: faqResponse.self, completion: { result in
                switch result{
                case .success(let response):
                    self.FAQs = response.data
                    self.delegate?.loadedFAQs()
                case .failure(let error):
                    debugPrint(error)
                }
            })
        }
    }
    
    
}
