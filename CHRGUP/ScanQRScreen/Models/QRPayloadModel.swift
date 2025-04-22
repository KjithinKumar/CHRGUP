//
//  QRPayloadModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 08/04/25.
//

import Foundation
struct QRPayloadContainer: Codable {
    let payload: QRPayload
}

struct QRPayload: Codable {
    let connectorId: Int
    let chargerId: String
}

struct DecryptedPayload: Decodable {
    let chargerId: String
    let connectorId: Int
}
