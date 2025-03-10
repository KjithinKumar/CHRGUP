//
//  UserRegistrationViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 10/03/25.
//

import Foundation
protocol UserRegistrationViewModelDelegate: AnyObject {
    func didSaveUserProfileSuccessfully(token: String?)
    func didFailToSaveUserProfile(error: String)
}
protocol UserRegistrationViewModelnterface{
    
    func saveUserProfile(userProfile: UserProfile)
}

class UserRegistrationViewModel : UserRegistrationViewModelnterface{
    weak var delegate: UserRegistrationViewModelDelegate?
    var networkManager: NetworkManager?
    
    init(delegate: UserRegistrationViewModelDelegate, networkManager: NetworkManager) {
        self.delegate = delegate
        self.networkManager = networkManager
    }
    
    func saveUserProfile(userProfile: UserProfile) {
        let url = URLs.postUserUrl
        guard let request = networkManager?.createRequest(urlString: url,
                                                          method: .post,
                                                          body: userProfile.toDictionary(),
                                                          encoding: .json,
                                                          headers: nil) else{
            delegate?.didFailToSaveUserProfile(error: "Invalid Request")
            return
        }
        networkManager?.request(request,
                                decodeTo: UserLoginResponseModel.self, completion: { result in
            switch result {
            case .success(let userResponse):
                debugPrint(userResponse)
                self.delegate?.didSaveUserProfileSuccessfully(token: userResponse.token)
            case .failure(let error) :
                self.delegate?.didFailToSaveUserProfile(error: error.localizedDescription)
            }
        })
    }
    
}
