//
//  LocationInfoViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/03/25.
//

import Foundation

enum locationInfoCellType{
    case chargers
    case tarrif
    case facilities
    case titleSubTitle
}

protocol LocationInfoViewModelInterface{
    var locationData : ChargerLocation? {get}
    var userLocationlatitude : Double? {get}
    var userLocationlongitude : Double? {get}
    var locationName : String {get}
    var distance : String {get}
    var isAvailable : Bool {get}
    var isFavourite : Bool {get}
    var locationImage : [String] {get}
    var locationCellType : [locationInfoCellType] {get}
    var pointsAvailable : String {get}
}

class LocationInfoViewModel : LocationInfoViewModelInterface{
    
    
    var locationData : ChargerLocation?
    var userLocationlatitude : Double?
    var userLocationlongitude : Double?
    init(locationData: ChargerLocation,latitude : Double,longitude : Double) {
        self.locationData = locationData
        self.userLocationlatitude = latitude
        self.userLocationlongitude = longitude
    }
    
    var locationName : String {
        return locationData?.locationName ?? "location"
    }
    var distance : String {
        return "\(locationData?.modDistance ?? "0") Kms"
    }
    var isAvailable : Bool {
        return locationData?.modLocationAvailble ?? false
    }
    var isFavourite: Bool {
        let userFavourite = UserDefaultManager.shared.getFavouriteLocations()
        return userFavourite.contains(where: { $0 == locationData?.id })
    }
    var locationImage : [String]{
        return locationData?.locationImage ?? []
    }
    
    var locationCellType : [locationInfoCellType] = [.chargers,.tarrif,.facilities,.titleSubTitle,.titleSubTitle,.titleSubTitle]
    
    var pointsAvailable : String {
        return "\(locationData?.modpointsAvailable ?? 0)"
    }
    
}
