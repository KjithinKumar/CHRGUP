//
//  DocumnetTypes.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 16/09/25.
//

import Foundation

enum DocumentTypes : String{
    case panCard = "pan"
    case drivingLicense = "driving_licence"
    case voterId = "voter_id"
    var displayName: String {
        switch self {
        case .panCard: return "PAN Card"
        case .drivingLicense: return "Driving License"
        case .voterId: return "Voter ID"
        }
    }
}
