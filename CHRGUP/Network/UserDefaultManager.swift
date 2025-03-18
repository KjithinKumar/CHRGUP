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
}
