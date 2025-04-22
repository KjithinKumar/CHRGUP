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
    
    static func imageUrl(_ imageName : String) -> String{
        return "\(baseUrls3)\(imageName)"
    }
    
    static func userVehiclesUrl(mobileNumber : String) -> String{
        return "\(baseUrl)users/\(mobileNumber)/vehicles"}
    
    static func deleteVehicleUrl(mobileNumber : String, VehicleId : String) -> String{
        return "\(baseUrl)users/\(mobileNumber)/vehicles/\(VehicleId)"
    }
    
    static func updateVehicleUrl(mobileNumber : String, VehicleId : String) -> String{
        return "\(baseUrl)users/\(mobileNumber)/vehicles/\(VehicleId)"
    }
    static let faqURl = baseUrl + "faq/all-faq-category"
    
    static let faqCatergoryUrl = baseUrl + "faq/faq-category"
    
    static let nearByChargersUrl = baseUrl + "charger-locations/location/near/range"
    
    static func addFavouriteLocationUrl (mobileNumber : String) -> String{
        return "\(baseUrl)users/\(mobileNumber)/add-favourite"
    }
    
    static func getFavouriteLocationUrl (mobileNumber : String) -> String{
        return "\(baseUrl)users/\(mobileNumber)/get-favourite"
    }
    static func deleteFavouriteLocationUrl (mobileNumber : String) -> String{
        return "\(baseUrl)users/\(mobileNumber)/favourite"
    }
    
    static func updateUserProfile(mobile : String) -> String{
        return "\(baseUrl)users/\(mobile)"
    }
    
    static func searchChargersUrl(searchText : String) -> String{
        return "\(baseUrl)charger-locations/location/search?query=\(searchText)"
    }
    
    static func getChargerByIdUrl(chargerId : String) -> String{
        return "\(baseUrl)charger-locations/\(chargerId)"
    }
    
    static let getChargerRange = baseUrl + "charger-locations/location/range"
    
    static func getChargerById (chargerId : String) -> String{
        return "\(baseUrl)charger-locations/\(chargerId)"
    }
    
    static let getChargerByName = baseUrl + "charger-locations/get-charger-info-by-name"
    
    static let sessionTransationUrl = baseUrl + "/session/transaction"
    
    static let reviewsUrl = baseUrl + "reviews"
    
    static let getChargingStatusUrl = baseUrl + "session/get-session-info"
    
    static func gethistoryUrl(mobileNumber : String) -> String{
        return "\(baseUrl)users/\(mobileNumber)/history"
    }
    static let getReceiptUrl = baseUrl + "session/get-session-receipt"
    
    static let razorPayBaseUrl : String = "https://api.razorpay.com/v1/"
    
    static let razorPayOrderUrl = razorPayBaseUrl + "orders"
    
    static func razorPayPaymentDetailUrl(paymentId : String) -> String{
        return razorPayBaseUrl + "payments/\(paymentId)"
    }
    
    static func capturePaymentUrl(paymentId : String) -> String{
        return razorPayBaseUrl + "payments/\(paymentId)/capture"
    }
    
    static let serverPaymentUrl = baseUrl + "payment"
    
    static func checkReviewExistUrl(mobileNumber : String, locationId : String) -> String{
        return "\(baseUrl)reviews/hasReviewed/\(mobileNumber)/\(locationId)"
    }
}
