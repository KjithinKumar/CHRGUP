//
//  NearByChargerViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 19/03/25.
//

import Foundation
import CoreLocation

protocol NearByChargerViewModelDelegate: AnyObject {
    
    
}

protocol NearByChargerViewModelInterface{
    func getNearByCharger(latitue: Double, longitude: Double, range : Int, mobileNumber: String, completion : @escaping (Result<ChargerLocationResponse, Error>) -> Void)
    func nearByChargerData() -> [ChargerLocation]
    func sortedNearByChargerData(currentLocation : CLLocation) -> [ChargerLocation]
}
class NearByChargerViewModel : NearByChargerViewModelInterface{
    var networkManager: NetworkManagerProtocol?
    weak var delegate : NearByChargerViewModelDelegate?
    var chargerLocationResponse : ChargerLocationResponse?
    
    init(networkManager: NetworkManagerProtocol, delegate: NearByChargerViewModelDelegate) {
        self.networkManager = networkManager
        self.delegate = delegate
    }
    
    func getNearByCharger(latitue: Double, longitude: Double, range : Int, mobileNumber: String, completion : @escaping (Result<ChargerLocationResponse, Error>) -> Void){
        let url = URLs.nearByChargersUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let body = ["latitude": latitue, "longitude": longitude, "range": range, "mobileNumber": mobileNumber] as [String : Any]
        let header = ["Authorization": "Bearer \(authToken)"]
        if let reqest = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(reqest, decodeTo: ChargerLocationResponse.self , completion: { result in
                switch result {
                case .success(let response):
                    self.chargerLocationResponse = response
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
    func nearByChargerData() -> [ChargerLocation]{
        return chargerLocationResponse?.data ?? []
    }
    
    func sortedNearByChargerData(currentLocation : CLLocation) -> [ChargerLocation]{
        return nearByChargerData().map { ChargerLocationProcessor.process($0, currentLocation: currentLocation) }
                .sorted { $0.distance ?? 0.0 < $1.distance ?? 0.0 }
    }
}
class ChargerLocationProcessor {
    
    static func process(_ charger: ChargerLocation, currentLocation: CLLocation) -> ChargerLocation {
        var updatedCharger = charger
        let chargerLocation = CLLocation(latitude: charger.direction.latitude, longitude: charger.direction.longitude)
        
        // Calculate Distance in KM
        let distance = currentLocation.distance(from: chargerLocation) / 1000
        updatedCharger.distance = distance
        updatedCharger.modDistance = String(format: "%.2f", distance)
        
        // Count available charging points
        updatedCharger.modpointsAvailable = charger.chargerInfo.filter { $0.status == "Available" }.count
        
        // Check if the charger is active
        updatedCharger.modLocationAvailble = isChargerActive(workingDays: charger.workingDays, workingHours: charger.workingHours) && charger.status == "Active"
        
        return updatedCharger
    }
    
    private static func isChargerActive(workingDays: String, workingHours: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hha" // Format for parsing "8am", "10pm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: Date()) // Sunday = 1, Monday = 2, etc.
        
        let dayMap: [String: Int] = [
            "Sunday": 1, "Monday": 2, "Tuesday": 3, "Wednesday": 4,
            "Thursday": 5, "Friday": 6, "Saturday": 7
        ]
        
        // If it’s available every day
        if workingDays.lowercased() == "everyday" {
            return true
        }
        
        let dayComponents = workingDays.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let startDay = dayMap[dayComponents.first ?? ""],
              let endDay = dayMap[dayComponents.last ?? ""] else {
            return false
        }
        
        if !(startDay...endDay).contains(currentDay) {
            return false
        }
        
        // If 24 hrs available
        if workingHours.lowercased() == "24hrs" || workingHours == "12am-12am" {
            return true
        }
        
        // Parse working hours
        let timeComponents = workingHours.components(separatedBy: "-")
        guard timeComponents.count == 2,
              let startTime = dateFormatter.date(from: timeComponents[0].trimmingCharacters(in: .whitespaces)),
              let endTime = dateFormatter.date(from: timeComponents[1].trimmingCharacters(in: .whitespaces)) else {
            return false
        }
        
        let currentFormatter = DateFormatter()
        currentFormatter.dateFormat = "hha"
        let currentTimeString = currentFormatter.string(from: Date())
        guard let currentTime = dateFormatter.date(from: currentTimeString) else {
            return false
        }
        
        return currentTime >= startTime && currentTime <= endTime
    }
}

