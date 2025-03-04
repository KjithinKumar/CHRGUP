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
                debugPrint(results as? String)
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
        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
        // Build the request body
        
        //request.httpBody = bodyParams.data(using: .utf8)
        // Set the headers
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        // Basic Auth: "AccountSID:AuthToken" Base64-encoded
        
        
        // Execute the network call
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            // Check for network or server errors
//            if let error = error {
//                completion(false, "Failed to verify code: \(error.localizedDescription)")
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion(false, "Invalid response.")
//                return
//            }
//            // Check for successful status code
//            guard (200...299).contains(httpResponse.statusCode) else {
//                let responseBody = String(data: data ?? Data(), encoding: .utf8) ?? "No response body"
//                completion(false, "Failed with status code \(httpResponse.statusCode): \(responseBody)")
//                return
//            }
//            // Attempt to parse the JSON response
//            guard let data = data else {
//                completion(false, "No data returned from server.")
//                return
//            }
//            do {
//                // Convert response to dictionary
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    let status = json["status"] as? String ?? ""
//                    let isVerified = (status == "approved")
//                    if isVerified {
//                        completion(true, nil)
//                    } else {
//                        completion(false, "Verification failed. Status: \(status)")
//                    }
//                } else {
//                    completion(false, "Invalid JSON structure.")
//                }
//            } catch {
//                completion(false, "JSON parsing error: \(error.localizedDescription)")
//            }
//        }.resume()
    }
}
