//
//  HelpAndSupportViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/03/25.
//

import Foundation

protocol HelpandSupportViewModelDelegate: AnyObject {
    func faqLoaded()
    
}

protocol HelpAndSupportViewModelProtocolInterface {
    var faqCategories : [String]? {get}
    func getFAQCategories()
}
class HelpAndSupportViewModel: HelpAndSupportViewModelProtocolInterface {
    var networkManager : NetworkManagerProtocol?
    weak var delegate : HelpandSupportViewModelDelegate?
    
    init(networkManager: NetworkManagerProtocol, delegate: HelpandSupportViewModelDelegate) {
        self.networkManager = networkManager
        self.delegate = delegate
    }
    var faqCategories : [String]?
    func getFAQCategories() {
        let url = URLs.faqURl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return}
        let headers = ["Authorization": "Bearer \(authToken)"]
        let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: headers)
        if let request = request {
            networkManager?.request(request, decodeTo: faqCategoryResponse.self, completion: { result in
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
}
