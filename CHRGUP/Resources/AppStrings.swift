//
//  AppStrings.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/02/25.
//

import Foundation
struct AppStrings {
    struct Common {
        
    }
    struct Alert {
        static let ok = "OK"
        static let cancel = "Cancel"
        static let update = "Update"
        static let later = "Later"
        static let updateNow = "Update Now"
        static let settings = "Settings"
        
        static let updateTitle = "Update Required"
        static let updateMessage = "New version available. Please update."
        static let noInternetTitle = "No Internet Connection"
        static let noInternetMessage = "Please turn on Mobile Data or Wi-Fi to continue."
    }
    
    struct Onboarding {
        static let onboardingTitleOne = "Discover CHRGUP"
        static let onboardingTitleTwo = "Scan QR"
        static let onboardingTitleThree = "Start Charging"
        
        static let onboardingSubtitleOne = "Explore Charging Docks around you, know their\ncurrent status & navigate to the location"
        static let onboardingSubtitleTwo = "To start start charging, scan the QR Code on the Dock"
        static let onboardingSubtitleThree = "Review the charging dock details and click on start\ncharging. Monitor the progress remotely too."
        
        static let onboardingImageOne = "Onboarding-03"
        static let onboardingImageTwo = "Onboarding-04"
        static let onboardingImageThree = "Onboarding-02"
    }
}
