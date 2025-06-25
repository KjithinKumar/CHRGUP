//
//  ConnectorDisplayModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/06/25.
//

import Foundation

struct ConnectorDisplayItem : Identifiable {
    let id = UUID()
    var chargerInfo: ChargerInfo
    var connector: Connector
}
