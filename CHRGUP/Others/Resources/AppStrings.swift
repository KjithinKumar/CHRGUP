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
    
    struct VehicleDetails{
        static let addVehicle = "Add Vehicle"
        static let addButtonTitle = "Add"
        static let editButtonTitle = "Edit"
        static let updateButtonTitle = "Update"
        static let editVechicle = "Edit Vehicle"
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
        static let toastMessage = "⚠️ Press back again to exit"
    }
    
    struct Map{
        static let scanButtonTitle = "   Scan QR"
    }
    
    struct leftMenu{
        static let Title = "What am i\nDriving today?"
        static let highlihtedTitle = "Driving"
        
        static let MyGarage = "My Garage"
        static let GarageImage = "car"
        
        static let FavouriteDocks = "Favourite Docks"
        static let FavouriteDockImage = "heart"
        
        static let History = "History"
        static let HistoryImage = "clock"
        
        static let HelpandSupport = "Help & Support"
        static let HelpandSupportImage = "phone.connection"
        
        static let Settings = "Settings"
        static let SettingsImage = "gear"
        
        static let Reservation = "Reservations"
        static let ReservationImage = "calendar.badge.clock"
    }
    
    struct Garage{
        static let Title = "My Garage"
    }
    
    struct NearByCharger{
        static let Title = "Nearby Chargers"
    }
    
    struct ChargerInfo{
        static let ChargersTitle = "CHARGERS"
        
        static let issueText = "Any issue with the charger? Raise a ticket"
        
        static let chargingTariffText = "CHARGING TARIFF"
        
        static let parkingTariffText = "PARKING TARIFF"
        
        static let facilityText = "FACILITIES"
        
        static let workingHoursText = "WORKING HOURS"
        
        static let AddressText = "ADDRESS"
        
        static let contactText = "CONTACT"
        
        static let reserveButtonTitle = " Reserve"
    }
    
    struct Settings{
        static let editProfileText = "Edit Profile"
        
        static let deleteAccountText = "Delete Account"
        
        static let logoutText = " Logout"
        
        static let settings = "Settings"
    }
    
    struct EditProfile{
        static let firstNameText = " First Name"
        
        static let firstNamePlaceholderText = "Enter your first name"
        
        static let lastnameText = "Last Name"
        
        static let lastnamePlaceholderText = "Enter your last name"
        
        static let emailText = "Email Id"
        
        static let emailPlaceholderText = "Enter your email id"
        
        static let genderText = "Gender"
        
        static let genderPlaceholderText = "Select your gender"
        
        static let dob = "Date of Birth (DD/MM/YYYY)"
        
        static let dobPlaceholderText = "Select your date of birth"
    }
    
    struct ScanQr{
        static let manualQrTitle = "Please enter the code\ndisplayed on the charger"
        
        static let connectorIdText = "Select Connector ID"
    }
    
    struct StartCharging{
        static let title = "Charger is ready to start"
        
        static let titleOne = "Charger Name"
        
        static let titleTwo = "Charger Location"
        
        static let titleThree = "Charger Type"
        
        static let titleFour = "Charging Tariff"
        
        static let titleFive = "Parking Tariff"
        
        static let downViewTitle = "Note: Make sure the charging gun is connected properly to the car"
    }
    
    struct Review{
        static let title = "Thank you for choosing us"
        
        static let subtitle = "Please rate your experience in using us and our location partner"
        
        static let subtitleOne = "Charging Experience"
        
        static let subtitleTwo = "Charging Location"
        
        static let commentsText = "Comments"
    }
    
    struct chargingStatus{
        static let title = "Charging in progress"
        
        static let energyConsumedText = "Energy Consumed"
        
        static let chargingTimeText = "Charging Time"
        
        static let stopChargingText = "Stop Charging"
    }
    struct History{
        static let completedText = "Completed"
        
        static let failed = "Failed"
        
        static let chargerIdText = "Charger Id"
        
        static let chargingTimeText = "Charging Time"
        
        static let chargingTypeText = "Charging Type"
        
        static let energyConsumedText = "Energy Consumed"
        
        static let trasactionIdText = "Transaction Id"
        
        static let paymentMethodText = "Payment Mode"
    }
    
    struct signUp{
        static let title = "Create an account to access\nmore features"
    }
    
    struct HelpandSupport{
        static let title = "Help & Support"
        
        static let trackTicketText = "Track ticket"
        
        static let raiseTicketText = "Raise ticket"
        
        static let generalFaqText = "General FAQ"
        
        static let customerServiceText = "Customer Service"
        
        static let customerServiceSubText = "Please select the issue and report it"
        
        static let categoryText = "Category"
        
        static let categoryPlaceholderText = "Select category"
        
        static let sessionText = "Session"
        
        static let sessionPlaceholderText = "Select session"
        
        static let subjectText = "Subject"
        
        static let subjectPlaceholderText = "Enter subject"
        
        static let messageText = "Message"
        
        static let messagePlaceholderText = "Enter message"
    }
    
    struct reserveCharger{
        static let reservationTitleText = "Reservations"
        
        static let reserveChargerTitleText = "Reserve Charger"
        
        static let reserveChargerText = "Choose the connector type"
        
        static let selectTimeText = "Select time to reserve (max 15 mins)"
        
        static let reserveButtonText = "Reserve"
        
        static let timeSubtitleText = "Charger will be reserved until : "
        
        static let allButtonText = "All"
        
        static let reservedButtonText = "  Reserved"
        
        static let completedButtonText = "  Completed"
        
        static let failedButtonText = "  Failed"
    }
}
