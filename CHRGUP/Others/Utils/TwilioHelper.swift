//
//  TwilioHelper.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 03/03/25.
//

import Foundation

struct TwilioVerifyResponse: Decodable {
    let status: String
}


struct TwilioHelper {
 
    // Twilio API Credentials
    private static let accountSid  = AppIdentifications.Twilio.accountSID
    private static let authToken   = AppIdentifications.Twilio.authToken
    private static let serviceSid  = AppIdentifications.Twilio.serviceSID
    
    
   
    //Send Verfication Code
    static func sendVerificationCode(to phoneNumber: String,completion: @escaping (String?) -> Void) {
        guard phoneNumber.hasPrefix("+") else {return}
        let urlString = URLs.TwilioUrlSendCode
        let bodyParams: [String: String] = [
            "To": phoneNumber,
            "Channel": "sms" // or "whatsapp"
        ]
        let networkManager = NetworkManager()
        let authString = "\(accountSid):\(authToken)"
        guard let authData = authString.data(using: .utf8) else {
            return
        }
        let headers = ["Authorization":"Basic \(authData.base64EncodedString())"]
        let request = networkManager.createRequest(urlString: urlString, method: .post, body: bodyParams, encoding: .urlEncoded, headers: headers)
        if let request = request{
            networkManager.postRequest(request: request) { results in
                debugPrint(results as? String ?? "sent")
                completion(results as? String)
            }
        }
    }

    static func verifyCode(phoneNumber: String,code: String,completion: @escaping (Bool, String?) -> Void) {
        let urlString = URLs.TwilioUrlVerifyCode
        
        // Prepare the request
        let networkManager = NetworkManager()
        let bodyParams = ["To" : phoneNumber, "Code" : code]
        let authString = "\(accountSid):\(authToken)"
        guard let authData = authString.data(using: .utf8) else {
            completion(false, "Failed to encode credentials.")
            return
        }
        let headers = ["Authorization":"Basic \(authData.base64EncodedString())"]
        
        let request = networkManager.createRequest(urlString: urlString, method: .post, body: bodyParams, encoding: .urlEncoded, headers: headers)
        
        if let request = request{
            networkManager.request(request, decodeTo: TwilioVerifyResponse.self) { result in
                switch result {
                case .success(let response):
                    completion(response.status == "approved", response.status)
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}
