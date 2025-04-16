//
//  HistoryViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/04/25.
//

import Foundation
protocol HistoryViewModelInterface{
    var onDataChanged: (() -> Void)? { get set }
    func fetchHistory(completion : @escaping (Result<HistoryResponseModel,Error>)-> Void)
    var filteredChargers: [HistoryModel] { get } 
    var currentFilter: ChargerFilter { get set }
}
class HistoryViewModel: HistoryViewModelInterface {
    var networkManager : NetworkManagerProtocol?
    var allChargers: [HistoryModel] = []
    var filteredChargers: [HistoryModel] = []
    var onDataChanged: (() -> Void)?
    var currentFilter: ChargerFilter = .all {
        didSet {
            applyFilter()
        }
    }
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
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
                            self.allChargers = data
                            self.applyFilter()
                        }
                    }
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            
            }
        }
    }
    func applyFilter() {
        switch currentFilter {
        case .all:
            filteredChargers = allChargers
        case .ac:
            filteredChargers = allChargers.filter { $0.chargerType == "AC" }
        case .dc:
            filteredChargers = allChargers.filter { $0.chargerType == "DC" }
        }
        onDataChanged?()
    }
}
