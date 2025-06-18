//
//  ChargingLiveActivityManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/04/25.
//

import Foundation
import ActivityKit

enum ChargingLiveActivityManager {
    private static var activity: Activity<ChargingLiveActivityAttributes>?
    private static var lastInitialTime: String = "00h : 00m"
    private static var lastInitialEnergy: String = "0.0000 kWh"
    private static var isManuallyEnded = false
    static var liveActivityId: String?
    
    static func startActivity(timeTitle: String, energyTitle: String, chargingTitle: String, initialTime: String = "00h : 00m", initialEnergy: String = "0.0000 kWh") async -> String?{
        if let _ = activity {
            //print("A live activity instance exists. Skipping start.")
            return nil
        }
        if #available(iOS 16.2, *) {
            let existingActivities = Activity<ChargingLiveActivityAttributes>.activities
            if let existing = existingActivities.first {
                reconnect(to: existing)
                return nil
            }
        }
        isManuallyEnded = false
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let attributes = ChargingLiveActivityAttributes(
                timeTitle: timeTitle,
                energyTitle: energyTitle,
            )
            
            let initialContentState = ChargingLiveActivityAttributes.ContentState(
                time: initialTime,
                energy: initialEnergy,
                chargingTitle: "Charging is in Progress"
                
            )
            
            let content = ActivityContent(state: initialContentState,
                                          staleDate: nil)
            
            do {
                let startedActivity = try Activity<ChargingLiveActivityAttributes>.request(
                    attributes: attributes,
                    content: content,
                    pushType: .token
                )
                self.activity = startedActivity
                observeActivityEnd(activity: startedActivity)
                for await tokenData in startedActivity.pushTokenUpdates {
                    let token = tokenData.map { String(format: "%02x", $0) }.joined()
                    self.liveActivityId = token
                    return token
                }
                print("Live activity started: \(startedActivity.id)")
            } catch {
                print("Failed to start live activity: \(error.localizedDescription)")
            }
        } else {
            print("Live Activities not authorized.")
        }
        return nil
    }
    
    static func updateActivity(time: String, energy: String,chargingTitle: String) async -> String?{
        if let activity = activity {
            self.lastInitialTime = time
            self.lastInitialEnergy = energy
            let updatedContentState = ChargingLiveActivityAttributes.ContentState(
                time: time,
                energy: energy,
                chargingTitle: chargingTitle
            )
            
            let updatedContent = ActivityContent(state: updatedContentState, staleDate: nil)
            
            await activity.update(updatedContent)
            print("Live activity updated.")
        } else {
            print("No live activity found. Restarting...")
            
            // START a new activity if none exists
            if let token = await startActivity(
                timeTitle: "Time Consumed",
                energyTitle: "Units Consumed",
                chargingTitle: "Charging is in Progress",
                initialTime: time,
                initialEnergy: energy
            ){
                return token 
            }
        }
        return nil
    }
    
    static func endActivity() async -> String? {
        guard let activity = activity else {
            //print("No live activity to end.")
            return liveActivityId
        }
        isManuallyEnded = true
        let finalContentState = ChargingLiveActivityAttributes.ContentState(
            time: lastInitialTime,
            energy: lastInitialEnergy,
            chargingTitle: "Charging Completed"
        )
        let finalContent = ActivityContent(state: finalContentState, staleDate: nil)
        await activity.end(finalContent, dismissalPolicy: .after(.distantFuture))
        print("Live activity ended.")
        return liveActivityId
    }
    private static func observeActivityEnd(activity: Activity<ChargingLiveActivityAttributes>) {
        Task {
            for await state in activity.activityStateUpdates {
                switch state {
                case .ended, .dismissed:
                    print("Live Activity ended or dismissed by user.")
                    self.activity = nil
                default:
                    break
                }
            }
        }
    }
//    @MainActor
//    private static func restartLiveActivity() async {
//        print("Attempting to restart Live Activity...")
//        
//        // Provide default values or store the previous titles somewhere if needed
//        let _ = await startActivity(
//            timeTitle: "Time Consumed",
//            energyTitle: "Units Consumed",
//            chargingTitle: "Charging is in Progress",
//            initialTime: lastInitialTime,
//            initialEnergy: lastInitialEnergy
//        )
//    }
    static func reconnect(to existingActivity: Activity<ChargingLiveActivityAttributes>) {
        debugPrint("reconnecting to existing live activity...")
        self.activity = existingActivity
        observeActivityEnd(activity: existingActivity)
        
        // Optionally restore token
        Task {
            for await tokenData in existingActivity.pushTokenUpdates {
                let token = tokenData.map { String(format: "%02x", $0) }.joined()
                self.liveActivityId = token
                break
            }
        }
    }
}
