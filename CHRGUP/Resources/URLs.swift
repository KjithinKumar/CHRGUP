//
//  URLs.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import Foundation
struct URLs{
    static let baseUrl = "https://cms.chrgup.in/api/"
    
    static let baseUrls3 = "https://chrgup.s3.ap-south-1.amazonaws.com/"
    
    static let settingsUrl = "App-Prefs:root=WIFI"
    
    static let mobileDataSettingsUrl = "App-Prefs:root=MOBILE_DATA_SETTINGS_ID"
    
    static let checkVersionUrl = baseUrl + "version?version=\(AppConstants.currentAppVersion)"
    
    static let appleTestUrl = "https://www.apple.com/library/test/success.html"
    
    static let termsUrl = "https://chrgup.in/terms-and-conditions"
    
    static let privacyUrl = "https://chrgup.in/privacy-policy"
    
    static let cancellaionPolicyUrl = "https://chrgup.in/cancellation-and-refund-policy"
    
    static let TwilioUrlSendCode = "https://verify.twilio.com/v2/Services/\(AppIdentifications.Twilio.serviceSID)/Verifications"
    
    static let TwilioUrlVerifyCode = "https://verify.twilio.com/v2/Services/\(AppIdentifications.Twilio.serviceSID)/VerificationCheck"
    
    static let checkUserUrl = baseUrl + "users/check-registration/"
    
    static let postUserUrl = baseUrl + "users/"
    
    static let vehiclesUrl = baseUrl + "vehicle/all"
}
