//
//  URLs.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import Foundation
struct URLs{
    static let baseUrl = "https://cms.chrgup.in/api/"
    
    static let settingsUrl = "App-Prefs:root=WIFI"
    
    static let mobileDataSettingsUrl = "App-Prefs:root=MOBILE_DATA_SETTINGS_ID"
    
    static let checkVersionUrl = baseUrl + "version?version=\(AppConstants.currentAppVersion)"
    
    static let appleTestUrl = "https://www.apple.com/library/test/success.html"
}
