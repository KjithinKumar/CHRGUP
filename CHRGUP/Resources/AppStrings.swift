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
        
        static let onboardingSubtitleOne = "Explore Charging Docks around you, know their current status & navigate to the location"
        static let onboardingSubtitleTwo = "To start start charging, scan the QR Code on the Dock"
        static let onboardingSubtitleThree = "Review the charging dock details and click on start charging. Monitor the progress remotely too."
        
        static let onboardingImageOne = "Onboarding-03"
        static let onboardingImageTwo = "Onboarding-04"
        static let onboardingImageThree = "Onboarding-02"
    }
    
    struct Welcome{
        static let welcomeTitle = "Welcome"
        static let welcomeSubtitle = "Create an account or login to start charging"
        static let signupTitle = "Doesn’t have an account? Sign Up"
        static let continueButtonTitle = " Continue with phone"
    }
    
    struct Auth{
        static let welcomeTitle = "Welcome"
        static let welcomBackTitle = "Welcome Back"
        static let welcomeSubtitle = "Enter your phone number to continue"
        static let placeHolder = "Enter mobile number"
        static let signUpButtonTitle = "Sign Up"
        static let signInButtonTitle = "Sign In"
        static let terms = "I agree to the Terms & Conditions, Privacy\nPolicy and Cancelation & Refund Policy."
    }
    
    struct MobileExtension{
        static let Ind = "+91 "
    }
    
    struct Otp{
        static let title = "OTP Verification"
        static let subtitle = "Otp has been sent to your mobile number ending with "
        static let resendOtp = "Resend OTP"
        static let resendIn = "Resend OTP in %d seconds"
        static let verifyButtonTitle = "Verify"
        static let verifyingButtonTitle = "Verifying..."
        static let verifiedButtonTitle = "Verified"
        static let verifyFailedButtonTitle = "Verify Failed"
    }
}
