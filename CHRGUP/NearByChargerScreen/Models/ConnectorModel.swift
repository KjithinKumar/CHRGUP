//
//  ConnectorModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/06/25.
//

import Foundation
struct Connector: Codable {
    let connectorId: Int
    var status: String
    let energyConsumption: String
    let qrCodeUrl: String?
    let lastPing: String?
    let id: String

    enum CodingKeys: String, CodingKey {
        case connectorId, status, energyConsumption, qrCodeUrl, lastPing
        case id = "_id"
    }
}
