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

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ urlRequest: URLRequest,decodeTo type: T.Type,completion: @escaping (Result<T, Error>) -> Void)
    func createRequest(with urlString: String, method: NetworkRequestType,body: [String :Any]?) -> URLRequest?
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
    
    func createRequest(with urlString: String, method: NetworkRequestType,body: [String :Any]?) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        if let body = body{
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            }catch {
                print("Error creating request body: \(error)")
                return nil
            }
        }
        request.httpMethod = method.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }
    
}
