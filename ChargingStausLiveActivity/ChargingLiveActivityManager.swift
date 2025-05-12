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
    
    static func startActivity(timeTitle: String, energyTitle: String, chargingTitle: String, initialTime: String = "00h : 00m", initialEnergy: String = "0.0000 kWh") {
        if let _ = activity {
            //print("A live activity instance exists. Skipping start.")
            return
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
                title: "Charging is in Progress"
                
            )
            
            let content = ActivityContent(state: initialContentState,
                                          staleDate: nil)
            
            do {
                let startedActivity = try Activity<ChargingLiveActivityAttributes>.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
                self.activity = startedActivity
                observeActivityEnd(activity: startedActivity)
                
                //print("Live activity started: \(startedActivity.id)")
            } catch {
                print("Failed to start live activity: \(error.localizedDescription)")
            }
        } else {
            //print("Live Activities not authorized.")
        }
    }
    
    static func updateActivity(time: String, energy: String) async {
        if let activity = activity {
            self.lastInitialTime = time
            self.lastInitialEnergy = energy
            let updatedContentState = ChargingLiveActivityAttributes.ContentState(
                time: time,
                energy: energy,
                title: "Charging is in Progress"
            )
            
            let updatedContent = ActivityContent(state: updatedContentState, staleDate: nil)
            
            await activity.update(updatedContent)
            //print("Live activity updated.")
        } else {
            //print("No live activity found. Restarting...")
            
            // START a new activity if none exists
            startActivity(
                timeTitle: "Time Consumed",
                energyTitle: "Units Consumed",
                chargingTitle: "Charging is in Progress",
                initialTime: time,
                initialEnergy: energy
            )
        }
    }
    
    static func endActivity() async {
        guard let activity = activity else {
            //print("No live activity to end.")
            return
        }
        isManuallyEnded = true
        let finalContentState = ChargingLiveActivityAttributes.ContentState(
            time: lastInitialTime,
            energy: lastInitialEnergy,
            title: "Charging Completed"
        )
        
        let finalContent = ActivityContent(state: finalContentState, staleDate: nil)
        
        await activity.end(finalContent, dismissalPolicy: .after(.distantFuture))
        //print("Live activity ended.")
    }
    private static func observeActivityEnd(activity: Activity<ChargingLiveActivityAttributes>) {
        Task {
            for await state in activity.activityStateUpdates {
                switch state {
                case .ended, .dismissed:
                    //print("Live Activity ended or dismissed by user.")
                    self.activity = nil
                    
                    // RESTART the Live Activity automatically
                    if !isManuallyEnded {
                        Task { @MainActor in
                            restartLiveActivity()
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    @MainActor
    private static func restartLiveActivity() {
        //print("Attempting to restart Live Activity...")
        
        // Provide default values or store the previous titles somewhere if needed
        startActivity(
            timeTitle: "Time Consumed",
            energyTitle: "Units Consumed",
            chargingTitle: "Charging is in Progress",
            initialTime: lastInitialTime,
            initialEnergy: lastInitialEnergy
        )
    }
}
