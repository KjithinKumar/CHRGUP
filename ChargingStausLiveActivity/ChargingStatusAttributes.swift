//
//  ChargingStatusAttributes.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/04/25.
//

import Foundation
import ActivityKit

struct ChargingLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var time : String
        var energy : String
        var chargingTitle : String
        
        init(time: String, energy: String, chargingTitle: String) {
            self.time = time
            self.energy = energy
            self.chargingTitle = chargingTitle
        }
    }
    var timeTitle : String
    var energyTitle : String
    
    
}
