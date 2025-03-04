//
//  NetworkManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import Foundation

enum NetworkRequestType : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkManagerError : Error {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case decodingFailed
    case noData
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Please check your URL"
        case .invalidRequest:
            return "Invalid Request"
        case .invalidResponse:
            return "Invalid Response"
        case .decodingFailed:
            return "Decoding Failed"
        case .noData:
            return "No Data"
        }
    }
}
enum RequestEncoding {
    case json
    case urlEncoded
}

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ urlRequest: URLRequest,decodeTo type: T.Type,completion: @escaping (Result<T, Error>) -> Void)
    func createRequest(urlString: String,
                       method: NetworkRequestType,
                       body: [String : String]?,
                       encoding: RequestEncoding,
                       headers: [String: String]?) -> URLRequest?
}

class NetworkManager: NetworkManagerProtocol {
    func request<T>(_ urlRequest: URLRequest, decodeTo type: T.Type, completion: @escaping (Result<T, any Error>) -> Void) where T : Decodable {
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let _ = error{
                completion(.failure(NetworkManagerError.invalidRequest))
                return
            }
            guard let data = data else{
                completion(.failure(NetworkManagerError.noData))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            }catch(let error){
                debugPrint(error)
                completion(.failure(NetworkManagerError.decodingFailed))
            }
        }
        task.resume()
    }
    func postRequest(request : URLRequest,completion : @escaping (Any?) -> Void){
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion("Network error: \(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion("Invalid response from server.")
                    return
                }
                let responseBody = String(data: data ?? Data(), encoding: .utf8) ?? "No response body"
                
                switch httpResponse.statusCode {
                case 200...299:
                    completion(nil) // OTP Sent Successfully
                case 400:
                    completion("Bad Request: Check request parameters.")
                case 401:
                    completion("Unauthorized: Invalid Twilio credentials.")
                case 404:
                    completion("Resource Not Found: Invalid API endpoint.")
                case 429:
                    completion("Too Many Requests: Rate limit exceeded. Try again later.")
                case 500...599:
                    completion("Twilio Server Error: Try again later.")
                default:
                    completion("Unexpected Error: \(responseBody)")
                }
            }
        }.resume()
    }
    
    func createRequest(urlString: String,method: NetworkRequestType,body: [String : String]?,encoding: RequestEncoding,headers: [String: String]?) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        if let body = body{
            switch encoding {
            case .json:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                } catch {
                    return nil
                }
                
            case .urlEncoded:
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let encodedBody = body
                    .map { key, value in
                        let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                        let encodedValue = (value).addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? value
                        return "\(encodedKey)=\(encodedValue)"
                    }
                    .joined(separator: "&")
                request.httpBody = encodedBody.data(using: .utf8)
            }
        }
        return request
    }
    
}
