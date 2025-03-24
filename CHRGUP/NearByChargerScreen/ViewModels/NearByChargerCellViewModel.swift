//
//  NearByChargerCellViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/03/25.
//

import Foundation
import UIKit

class NearByChargerCellViewModel{
    var chargerLocationData : ChargerLocation
    var networkManager : NetworkManagerProtocol?
    init (chargerLocationData : ChargerLocation) {
        self.chargerLocationData = chargerLocationData
    }
    var locationName : String {
        return chargerLocationData.locationName
    }
    var parkingTypeText: String {
        return chargerLocationData.freePaid.parking ? "Free Parking" : "Paid Parking"
    }

    var parkingTypeColor: UIColor {
        return chargerLocationData.freePaid.parking ? ColorManager.primaryColor : ColorManager.subtitleTextColor
    }

    var chargingTypeText: String {
        return chargerLocationData.freePaid.charging ? "Free Charging" : "Paid Charging"
    }

    var chargingTypeColor: UIColor {
        return chargerLocationData.freePaid.charging ? ColorManager.primaryColor : ColorManager.subtitleTextColor
    }
    
    var distance : String {
        var formattedDistance = ""
        if let distanceDouble = chargerLocationData.distance {
            formattedDistance = String(format: "%.2f", distanceDouble)
        }
        return formattedDistance
    }
    var chargerLocationAvailable : Bool {
        return isChargerActive(workingDays: chargerLocationData.workingDays, workingHours: chargerLocationData.workingHours) && chargerLocationData.status == "Active"
    }
    var facilities : [String] {
        var names : [String] = []
        if let facility = chargerLocationData.facilities {
            names = facility.map { $0.name }
        }
        return names
    }
    var pointsAvailable : Int {
        let chargersStatus = chargerLocationData.chargerInfo.map { $0.status }
        var pointsAvailableCount = 0
        for status in chargersStatus {
            if status == "Active" {
                pointsAvailableCount += 1
            }
        }
        return pointsAvailableCount
        
    }
    
    var isFavouriteLocation : Bool {
        let favourites = UserDefaultManager.shared.getFavouriteLocations()
        let locationId = chargerLocationData.id
        return favourites.contains(where: { $0 == locationId })
    }
    
    func openLocationInMaps() {
        let latitude = chargerLocationData.direction.latitude
        let longitude = chargerLocationData.direction.longitude
        let appleMapsURL = "http://maps.apple.com/?q=\(latitude),\(longitude)&dirflg=d"
        let googleMapsURL = "comgooglemaps://?q=\(latitude),\(longitude)&directionsmode=driving"

        if let googleMaps = URL(string: googleMapsURL), UIApplication.shared.canOpenURL(googleMaps) {
            UIApplication.shared.open(googleMaps, options: [:], completionHandler: nil) // Open Google Maps
        } else if let appleMaps = URL(string: appleMapsURL) {
            UIApplication.shared.open(appleMaps, options: [:], completionHandler: nil) // Open Apple Maps
        }
    }
    
    private func isChargerActive(workingDays: String, workingHours: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hha" // Format for parsing "8am", "10pm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let calendar = Calendar.current
        let currentDay = calendar.component(.weekday, from: Date()) // Sunday = 1, Monday = 2, etc.
        
        // Convert working days to a valid range
        let dayMap: [String: Int] = [
            "Sunday": 1, "Monday": 2, "Tuesday": 3, "Wednesday": 4,
            "Thursday": 5, "Friday": 6, "Saturday": 7
        ]
        
        let dayComponents = workingDays.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let startDay = dayMap[dayComponents.first ?? ""],
              let endDay = dayMap[dayComponents.last ?? ""] else {
            return false
        }
        
        // Check if today is within the working days range
        if !(startDay...endDay).contains(currentDay) {
            return false
        }
        
        // Split the working hours string into start and end time
        let timeComponents = workingHours.components(separatedBy: "-")
        guard timeComponents.count == 2,
              let startTime = dateFormatter.date(from: timeComponents[0].trimmingCharacters(in: .whitespaces)),
              let endTime = dateFormatter.date(from: timeComponents[1].trimmingCharacters(in: .whitespaces)) else {
            return false
        }
        
        // Get the current time
        let currentFormatter = DateFormatter()
        currentFormatter.dateFormat = "hha"
        let currentTimeString = currentFormatter.string(from: Date())
        guard let currentTime = dateFormatter.date(from: currentTimeString) else {
            return false
        }
        
        // Check if current time is within working hours
        return currentTime >= startTime && currentTime <= endTime
    }
    
    func addToFavourtie(networkManager : NetworkManagerProtocol,completion: @escaping (Result<FavouriteResponseModel, Error>) -> Void){
        let locationId = chargerLocationData.id
        UserDefaultManager.shared.saveFavouriteLocation(locationId)
        let userDetails = UserDefaultManager.shared.getUserProfile()
        guard let mobileNumber = userDetails?.phoneNumber else {
            return
        }
        let url = URLs.addFavouriteLocationUrl(mobileNumber: mobileNumber)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let requestBody : [String : Any] = ["locationId" : locationId]
        let header = ["Authorization": "Bearer \(authToken)"]
        if let request = networkManager.createRequest(urlString: url, method: .post, body: requestBody, encoding: .json, headers: header){
            networkManager.request(request, decodeTo: FavouriteResponseModel.self) { result in
                switch result{
                case .success(let response):
                    completion(.success(response))
                case .failure(let error) :
                    completion(.failure(error))
                }
            }
        }
        
    }
}

