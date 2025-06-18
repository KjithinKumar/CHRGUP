//
//  UserDefaultManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/03/25.
//

import Foundation

class UserDefaultManager{
    static let shared = UserDefaultManager()
    
    private let defaults = UserDefaults.standard
    
    private let value = 0
    
    private enum Keys{
        static let isOnboardingCompleted = "isOnboardingCompleted"
        static let userProfile = "userProfile"
        static let selectedVehicle = "selectedVehicle"
        static let jwtTokenKey = "JWTKey"
        static let loggedInUserIdKey = "loggedInUserIdKey"
        static let favouriteLocationskey = "FavouriteLocations"
        static let userLocationKey = "userLocationKey"
        static let recentSearchHistoryKey = "recentSearchHistoryKey"
        static let chargerIdKey = "chargerIdKey"
        static let sessionStartTimeKey = "sessionTimeKey"
        static let scannedLocationId = "scannedLocationId"
        static let showPopupKey = "showPopupKey"
        static let sessionIdKey = "sessionIdKey"
        static let sessionStatusKey = "sessionStatusKey"
        static let appearanceKey = "AppAppearance"
    }
    
    // MARK: - User Profile
    func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            defaults.set(encoded, forKey: Keys.userProfile)
        }
    }
    func getUserProfile() -> UserProfile? {
        if let savedData = defaults.data(forKey: Keys.userProfile),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
            return decoded
        }
        return nil
    }
    func removeUserProfile() { defaults.removeObject(forKey: Keys.userProfile) }
    func deleteUserProfile() {
        removeJWTToken()
        removeUserProfile()
        removeRecentChargers()
        resetLoginStatus()
        resetFavouriteLocations()
        resetSelectedVehicle()
    }
    func logoutUserProfile() {
        resetLoginStatus()
        resetFavouriteLocations()
        resetSelectedVehicle()
        removeJWTToken()
        removeUserProfile()
        removeRecentChargers()
        removeChargerId()
        deleteSessionDetails()
    }
    // MARK: - Onboarding Completion Status
       func setOnboardingCompleted(_ completed: Bool) {
           defaults.set(completed, forKey: Keys.isOnboardingCompleted)
           defaults.synchronize()
       }

       func isOnboardingCompleted() -> Bool {
           return defaults.bool(forKey: Keys.isOnboardingCompleted)
       }

       func resetOnboarding() {
           defaults.removeObject(forKey: Keys.isOnboardingCompleted)
       }
    
    // MARK: - JWT Token
    func setJWTToken(_ token: String) {
        defaults.set(token, forKey: Keys.jwtTokenKey)
    }
    
    func getJWTToken() -> String? {
        return defaults.string(forKey: Keys.jwtTokenKey)
    }
    func removeJWTToken() {
        defaults.removeObject(forKey: Keys.jwtTokenKey)
    }
    //MARK: - Login Stats
    func setLoginStatus(_ status: Bool) {
        defaults.set(status, forKey: Keys.loggedInUserIdKey)
        if !status{
            resetFavouriteLocations()
            removeChargerId()
            deleteSessionDetails()
        }
    }
    func isLoggedIn() -> Bool {
        return defaults.bool(forKey: Keys.loggedInUserIdKey)
    }
    func resetLoginStatus() {
        defaults.removeObject(forKey: Keys.loggedInUserIdKey)
    }
    //MARK: - SelectedVehicle
    func saveSelectedVehicle(_ vehicle: VehicleModel?) {
        if let encoded = try? JSONEncoder().encode(vehicle) {
            defaults.set(encoded, forKey: Keys.selectedVehicle)
        }
    }
    func getSelectedVehicle() -> VehicleModel? {
        if let savedData = defaults.data(forKey: Keys.selectedVehicle),
           let decoded = try? JSONDecoder().decode(VehicleModel.self, from: savedData) {
            return decoded
        }
        return nil
    }
    func resetSelectedVehicle() {
        defaults.removeObject(forKey: Keys.selectedVehicle)
    }
    //MARK: - FavouriteLocation
    func saveFavouriteLocation(_ locationId: String ) {
        // Retrieve existing favorites or initialize an empty array
        var favourites = UserDefaults.standard.array(forKey: Keys.favouriteLocationskey) as? [String] ?? []
        
        // Append only if it's not already in the list
        if !favourites.contains(locationId) {
            favourites.append(locationId)
            UserDefaults.standard.set(favourites, forKey: Keys.favouriteLocationskey)
        }
    }
    func getFavouriteLocations() -> [String] {
        return UserDefaults.standard.array(forKey: Keys.favouriteLocationskey) as? [String] ?? []
    }
    func removeFavouriteLocation(_ locationId: String) {
        var favourites = UserDefaults.standard.array(forKey: Keys.favouriteLocationskey) as? [String] ?? []
        if let index = favourites.firstIndex(of: locationId) {
            favourites.remove(at: index)
        }
        UserDefaults.standard.setValue(favourites, forKey: Keys.favouriteLocationskey)
    }
    func resetFavouriteLocations() {
        UserDefaults.standard.removeObject(forKey: Keys.favouriteLocationskey)
    }
    
    //MARK: - CurrentLocation
    func saveUserCurrentLocation(_ latitude : Double,_ longitude : Double){
        UserDefaults.standard.setValue([latitude,longitude], forKey: Keys.userLocationKey)
        UserDefaults.standard.synchronize()
    }
    func getUserCurrentLocation() -> [Double]?{
        return UserDefaults.standard.array(forKey: Keys.userLocationKey) as? [Double]
    }
    func resetUserCurrentLocation() {
        UserDefaults.standard.removeObject(forKey: Keys.userLocationKey)
    }
    //MARK: - RecentChargerLocation
    func saveRecentChargers(_ chargers: [LocationData]) {
        if let encoded = try? JSONEncoder().encode(chargers) {
            UserDefaults.standard.set(encoded, forKey: Keys.recentSearchHistoryKey)
        }
    }
    func getRecentChargers() -> [LocationData]? {
        if let data = UserDefaults.standard.data(forKey: Keys.recentSearchHistoryKey),
           let decoded = try? JSONDecoder().decode([LocationData].self, from: data) {
            return decoded
        }
        return []
    }
    func removeRecentChargers() {
        UserDefaults.standard.removeObject(forKey: Keys.recentSearchHistoryKey)
    }
    //MARK: -  ChargerId
    func saveChargerId(_ chargerId: String) {
        UserDefaults.standard.setValue(chargerId, forKey: Keys.chargerIdKey)
        UserDefaults.standard.synchronize()
    }
    func getChargerId() -> String? {
        return UserDefaults.standard.string(forKey: Keys.chargerIdKey)
    }
    func removeChargerId() {
        UserDefaults.standard.removeObject(forKey: Keys.chargerIdKey)
    }
    
    func saveTimestamp(){
        let currentTime = Date().timeIntervalSince1970
        UserDefaults.standard.setValue(currentTime, forKey: Keys.sessionStartTimeKey)
        UserDefaults.standard.synchronize()
    }
    func saveSessionStartTime(_ timeStamp: String) {
        UserDefaults.standard.setValue(timeStamp, forKey: Keys.sessionStartTimeKey)
        UserDefaults.standard.synchronize()
    }
    func getSessionStartTime() -> String? {
        return UserDefaults.standard.string(forKey: Keys.sessionStartTimeKey)
    }
    func deleteSessionStartTime() {
        UserDefaults.standard.removeObject(forKey: Keys.sessionStartTimeKey)
    }
    
    //MARK: - ScannedLocation
    func saveScannedLocation(_ locationId: String) {
        UserDefaults.standard.setValue(locationId, forKey: Keys.scannedLocationId)
        UserDefaults.standard.synchronize()
    }
    
    func getScannedLocationId() -> String? {
        return UserDefaults.standard.string(forKey: Keys.scannedLocationId)
    }
    func deleteScannedLocationId() {
        UserDefaults.standard.removeObject(forKey: Keys.scannedLocationId)
    }
    
    //MARK: - PopUpTime
    func showPopUp() -> Bool {
        let currentValue = UserDefaults.standard.integer(forKey: Keys.showPopupKey)
        UserDefaults.standard.set(currentValue + 1, forKey: Keys.showPopupKey)
        return UserDefaults.standard.integer(forKey: Keys.showPopupKey) <= 2
    }
    func resetPopUp() {
        UserDefaults.standard.removeObject(forKey: Keys.showPopupKey)
    }
    
    //MARK: - SessionId
    func saveSessionId(_ sessionId: String?) {
        UserDefaults.standard.setValue(sessionId, forKey: Keys.sessionIdKey)
    }
    func saveSessionStatus(_ sessionStatus : String?) {
        UserDefaults.standard.set(sessionStatus, forKey: Keys.sessionStatusKey)
    }
    func getSessionId() -> String? {
        return UserDefaults.standard.string(forKey: Keys.sessionIdKey)
    }
    func getSessionStatus() -> String? {
        return UserDefaults.standard.string(forKey: Keys.sessionStatusKey)
    }
    func IsSessionActive() -> Bool {
        let sessionStatus = getSessionStatus()
        if sessionStatus == "Started" {
            return true
        }else{
            return false
        }
    }
    func deleteSessionDetails() {
        UserDefaults.standard.removeObject(forKey: Keys.sessionIdKey)
        UserDefaults.standard.removeObject(forKey: Keys.sessionStatusKey)
        UserDefaults.standard.removeObject(forKey: Keys.sessionStartTimeKey)
    }
    static var appAppearance: AppAppearance {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: Keys.appearanceKey),
               let mode = AppAppearance(rawValue: rawValue) {
                return mode
            }
            return .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.appearanceKey)
        }
    }
}
