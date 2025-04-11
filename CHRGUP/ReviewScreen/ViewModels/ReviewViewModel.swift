//
//  RatingViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 10/04/25.
//

import Foundation
protocol ReviewViewModelInterface {
    func submitReview(charging : Int, location : Int, comments : String, completion : @escaping (Result<ReviewResponseModel, Error>) -> Void)
}

class ReviewViewModel: ReviewViewModelInterface {
    var networkManager: NetworkManagerProtocol?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func submitReview(charging : Int, location : Int, comments : String, completion : @escaping (Result<ReviewResponseModel, Error>) -> Void) {
        let url = URLs.reviewsUrl
        guard let phoneNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else {return}
        guard let locationId = UserDefaultManager.shared.getScannedLocationId() else {return}
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        let body : [String : Any] = [ "phoneNumber": phoneNumber,
                     "location": locationId,
                     "charging_exp": charging,
                     "charging_location": location,
                     "review": comments]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: ReviewResponseModel.self) { [weak self] result in
                guard let _ = self else { return }
                switch result {
                    case .success(let response):
                    completion(.success(response))
                    case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
    }
}
