//
//  OtherDataModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/06/25.
//

import Foundation

struct OtherData: Codable {
    let chargePointVendor: String
    let chargePointModel: String
    let chargeBoxSerialNumber: String
    let chargePointSerialNumber: String
    let meterType: String
    let iccid: String?
    let imsi: String?
    let firmwareVersion: String
}
