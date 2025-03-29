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
    
    private enum Keys{
        static let isOnboardingCompleted = "isOnboardingCompleted"
        static let userProfile = "userProfile"
        static let selectedVehicle = "selectedVehicle"
        static let jwtTokenKey = "JWTKey"
        static let loggedInUserIdKey = "loggedInUserIdKey"
        static let favouriteLocationskey = "FavouriteLocations"
        static let userLocationKey = "userLocationKey"
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
    
    //MARK: - Login Stats
    func setLoginStatus(_ status: Bool) {
        defaults.set(status, forKey: Keys.loggedInUserIdKey)
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
    //MARK: - FavouriteLocation
    func saveFavouriteLocation(_ locationId: String ) {
        // Retrieve existing favorites or initialize an empty array
        var favourites = UserDefaults.standard.array(forKey: Keys.favouriteLocationskey) as? [String] ?? []
        
        // Append only if it's not already in the list
        if !favourites.contains(locationId) {
            favourites.append(locationId)
            UserDefaults.standard.setValue(favourites, forKey: Keys.favouriteLocationskey)
            UserDefaults.standard.synchronize()
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
    func saveUserCurrentLocation(_ latitude : Double,_ longitude : Double){
        UserDefaults.standard.setValue([latitude,longitude], forKey: Keys.userLocationKey)
        UserDefaults.standard.synchronize()
    }
    func getUserCurrentLocation() -> [Double]?{
        return UserDefaults.standard.array(forKey: Keys.userLocationKey) as? [Double]
    }
    
}
