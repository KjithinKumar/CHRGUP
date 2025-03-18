//
//  CheckUserViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 04/03/25.
//

import Foundation
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

enum VerifyState {
    case verify
    case verifying
    case verified
}


protocol OtpViewModelDelegate : AnyObject {
    func didRegisterSuccessfully(userProfile: UserProfile, sessionData: SessionData?,token: String)
    func didFailToRegister(error: String)
    func didRequireGoogleSignIn()
}

protocol OtpViewModelInterface: AnyObject {
    func checkUserRegistration(phoneNumber: String)
    var delegate: OtpViewModelDelegate? { get set }
    func verifyOtp(phoneNumber: String, otp: String,completion : @escaping (String,Bool)->(Void))
    func resendOtp(phoneNumber: String,completion: @escaping(String)->Void)
}
class OtpViewModel: OtpViewModelInterface {
    weak var delegate : OtpViewModelDelegate?
    var networkManager : NetworkManagerProtocol?
    
    init(delegate: OtpViewModelDelegate, networkManager: NetworkManagerProtocol) {
        self.delegate = delegate
        self.networkManager = networkManager
    }
    func verifyOtp(phoneNumber: String, otp: String,completion : @escaping (String,Bool)->(Void)) {
        TwilioHelper.verifyCode(phoneNumber: phoneNumber, code: otp) { [weak self] success, value in
            guard let _ = self else { return }
            DispatchQueue.main.async {
                if success {
                    completion("Verfied",true)
                } else {
                    completion("Invalid opt",false)
                }
            }
        }
    }
    func resendOtp(phoneNumber: String,completion: @escaping(String)->Void) {
        TwilioHelper.sendVerificationCode(to: phoneNumber) { result in
            if let error = result {
                completion(error)
            } else {
                completion("OTP resent successfully")
            }
        }
    }
    
    func checkUserRegistration(phoneNumber: String) {
        let url = URLs.checkUserUrl + phoneNumber
        guard let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: nil) else {
            return
        }
        networkManager?.request(request, decodeTo: UserLoginResponseModel.self, completion: { result in
            switch result{
            case .success(let response):
                if response.success,let userProfile = response.data{
                    let sessionData = SessionData(sessionId: response.sessionId, locationId: response.locationId, startTime: response.startTime, chargerId: response.chargerId, status: response.status)
                    let token = response.token ?? ""
                    self.delegate?.didRegisterSuccessfully(userProfile: userProfile, sessionData: sessionData, token: token)
                }else{
                    self.delegate?.didRequireGoogleSignIn()
                }
            case .failure(let error):
                self.delegate?.didFailToRegister(error: error.localizedDescription)
            }
        })
    }
}

