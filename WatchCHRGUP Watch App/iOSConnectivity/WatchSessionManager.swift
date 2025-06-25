//
//  WatchSessionManager.swift
//  WatchCHRGUP Watch App
//
//  Created by Jithin Kamatham on 21/06/25.
//

import Foundation
import WatchConnectivity

class WatchSessionManager : NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    @Published var isLoggedIn: Bool = UserDefaultManager.shared.isLoggedIn()
    @Published var isSessionActive: Bool = UserDefaultManager.shared.IsSessionActive()
    @Published var userLocation = UserDefaultManager.shared.getUserCurrentLocation()
    override init() {
        super.init( )
        guard WCSession.isSupported() else {
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
           // print("Watch: Session activated.")
        } else {
            print("Watch: Session activation failed with state: \(activationState) and error: \(String(describing: error?.localizedDescription))")
        }
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch: Reachability changed: \(session.isReachable)")
        if session.isReachable {
            
        }
    }
    func isSesssionActive(isActive: Bool){
        DispatchQueue.main.async {
            self.isSessionActive = isActive
            print("session active \(isActive)")
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        debugPrint("userInfo from iphone \(userInfo)")
        DispatchQueue.main.async {
            if let authToken = userInfo[MessageKeys.AuthToken] as? String {
                if authToken != "" {
                    UserDefaultManager.shared.setJWTToken(authToken)
                }else{
                    UserDefaultManager.shared.removeJWTToken()
                }
            }
            if let login = userInfo[MessageKeys.loginStatus] as? Bool {
                UserDefaultManager.shared.setLoginStatus(login)
                self.isLoggedIn = login
            }else{
                UserDefaultManager.shared.resetLoginStatus()
            }
            if let profileData = userInfo[MessageKeys.userProfile] as? Data {
                do {
                    let userProfile = try JSONDecoder().decode(UserProfile.self, from: profileData)
                    UserDefaultManager.shared.saveUserProfile(userProfile)
                } catch {
                    print("Error decoding user profile: \(error)")
                }
            }else{
                UserDefaultManager.shared.deleteUserProfile()
            }
            if let selectedVehicle = userInfo[MessageKeys.selectedVehicle] as? Data {
                do {
                    let vehicle = try JSONDecoder().decode(VehicleModel.self, from: selectedVehicle)
                    UserDefaultManager.shared.saveSelectedVehicle(vehicle)
                }catch{
                    print("Error decoding selected vehicle: \(error)")
                }
            }else{
                UserDefaultManager.shared.resetSelectedVehicle()
            }
            if let chargerId = userInfo[MessageKeys.chargerId] as? String {
                if chargerId != ""{
                    UserDefaultManager.shared.saveChargerId(chargerId)
                }else{
                    UserDefaultManager.shared.removeChargerId()
                }
            }
            if let sessionStatus = userInfo[MessageKeys.sessionStatus] as? String {
                if sessionStatus != ""{
                    UserDefaultManager.shared.saveSessionStatus(sessionStatus)
                    if sessionStatus == "Started"{
                        self.isSesssionActive(isActive: true)
                    }
                }else{
                    self.isSesssionActive(isActive: false)
                    UserDefaultManager.shared.deleteSessionDetails()
                }
                
            }
            if let scannedLocation = userInfo[MessageKeys.locationId] as? String {
                if scannedLocation != ""{
                    UserDefaultManager.shared.saveScannedLocation(scannedLocation)
                }else{
                    UserDefaultManager.shared.deleteScannedLocationId()
                }
            }
            if let sessionId = userInfo[MessageKeys.sessionId] as? String {
                if sessionId != ""{
                    UserDefaultManager.shared.saveSessionId(sessionId)
                }else{
                    UserDefaultManager.shared.deleteSessionDetails()
                }
            }
            if let userLocation = userInfo[MessageKeys.userLocation] as? [Double] {
                if userLocation != []{
                    if let lat = userLocation.first, let long = userLocation.last{
                        UserDefaultManager.shared.saveUserCurrentLocation(lat, long)
                        self.userLocation = UserDefaultManager.shared.getUserCurrentLocation()
                    }
                }
            }
        }
    }

    func sendDataToIphone(){
        var infoTOsend : [String : Any] = [:]
        infoTOsend[MessageKeys.locationId] = UserDefaultManager.shared.getScannedLocationId() ?? ""
        infoTOsend[MessageKeys.chargerId] = UserDefaultManager.shared.getChargerId() ?? ""
        infoTOsend[MessageKeys.sessionId] = UserDefaultManager.shared.getSessionId() ?? ""
        infoTOsend[MessageKeys.sessionStatus] = UserDefaultManager.shared.getSessionStatus() ?? ""
        infoTOsend[MessageKeys.sessionStartTime] = UserDefaultManager.shared.getSessionStartTime() ?? ""
        WCSession.default.transferUserInfo(infoTOsend)
    }

}
