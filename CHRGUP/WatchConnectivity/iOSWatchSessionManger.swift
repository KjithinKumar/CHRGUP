//
//  iOSWatchSessionManger.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 21/06/25.
//

import Foundation
import WatchConnectivity

class iOSWatchSessionManger: NSObject, WCSessionDelegate,ObservableObject {

    static let shared = iOSWatchSessionManger()
    
    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let request = message[MessageKeys.requestStatus] as? String {
            if request == MessageValues.getLoginStatus {
                let status = UserDefaultManager.shared.isLoggedIn()
                replyHandler([MessageKeys.loginStatus : status])
            } else {
                replyHandler([:])
            }
        } else {
            replyHandler([:])
        }
    }
    func sendStatusToWatch() {
        var infoTOsend : [String:Any] = [:]
        let loginStatus = UserDefaultManager.shared.isLoggedIn()
        infoTOsend[MessageKeys.loginStatus] = loginStatus
        infoTOsend[MessageKeys.AuthToken] = UserDefaultManager.shared.getJWTToken() ?? ""
        infoTOsend[MessageKeys.chargerId] = UserDefaultManager.shared.getChargerId() ?? ""
        infoTOsend[MessageKeys.sessionStatus] = UserDefaultManager.shared.getSessionStatus() ?? ""
        infoTOsend[MessageKeys.sessionStartTime] = UserDefaultManager.shared.getSessionStartTime() ?? ""
        infoTOsend[MessageKeys.locationId] = UserDefaultManager.shared.getScannedLocationId() ?? ""
        infoTOsend[MessageKeys.sessionId] = UserDefaultManager.shared.getSessionId() ?? ""
        infoTOsend[MessageKeys.userLocation] = UserDefaultManager.shared.getUserCurrentLocation() ?? []

        if let profileData = UserDefaultManager.shared.getUserProfile(){
            do {
                let profile = try JSONEncoder().encode(profileData)
                infoTOsend[MessageKeys.userProfile] = profile
            }catch {
                print(error.localizedDescription)
            }
        }
        if let selectedVehile = UserDefaultManager.shared.getSelectedVehicle(){
            do {
                let vehicle = try JSONEncoder().encode(selectedVehile)
                infoTOsend[MessageKeys.selectedVehicle] = vehicle
            }catch{
                print(error.localizedDescription)
            }
        }

        WCSession.default.transferUserInfo(infoTOsend)
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if activationState == .activated {
            sendStatusToWatch()
        } else {
            print("iOS: WCSession activation failed with state: \(activationState) and error: \(String(describing: error?.localizedDescription))")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOS: WCSession became inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let locationId = userInfo[MessageKeys.locationId] as? String {
            if locationId != ""{
                UserDefaultManager.shared.saveScannedLocation(locationId)
            }else{
                UserDefaultManager.shared.deleteScannedLocationId()
            }
        }
        if let chargeID = userInfo[MessageKeys.chargerId] as? String {
            if chargeID != ""{
                UserDefaultManager.shared.saveChargerId(chargeID)
            }else{
                UserDefaultManager.shared.removeChargerId()
            }
        }
        if let sessionId = userInfo[MessageKeys.sessionId] as? String {
            if sessionId != ""{
                UserDefaultManager.shared.saveSessionId(sessionId)
            }
        }
        if let sessionStatus = userInfo[MessageKeys.sessionStatus] as? String {
            if sessionStatus != ""{
                UserDefaultManager.shared.saveSessionStatus(sessionStatus)
            }
        }
        if let sessionStartTime = userInfo[MessageKeys.sessionStartTime] as? String {
            if sessionStartTime != ""{
                UserDefaultManager.shared.saveSessionStartTime(sessionStartTime)
            }else{
                UserDefaultManager.shared.deleteSessionStartTime()
            }
        }
    }
}
