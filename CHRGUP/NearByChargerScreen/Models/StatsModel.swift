//
//  StatsModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/06/25.
//

import Foundation

struct Stats: Codable {
    let totalEnergyConsumed: String
    let totalSessions: Int
    let occupancyRate: String
    let kmPowered: String
    let co2Saved: String
    let uptimeRate: String
}
