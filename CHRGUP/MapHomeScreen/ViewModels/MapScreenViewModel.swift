//
//  MapScreenViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 12/03/25.
//

import Foundation
import CoreLocation

protocol MapViewModelDelegate : AnyObject {
    func didUpdateUserLocation(_ location: CLLocation)
    func didFailWithError(_ error: Error)
}
protocol MapScreenViewModelInterface : AnyObject{
    var delegate: MapViewModelDelegate? { get set }
    func requestLocationPermissionIfNeeded()
    func isLocationPermissionGranted() -> Bool
    func fetchchargerLocation(lat : Double, lon : Double, range : Int,completion : @escaping (Result<ChargerRangeresponse,Error>) -> Void)
    func fetchLocationById(id : String,completion : @escaping (Result<ChargerLocationResponseById,Error>) -> Void)
    func fetchChargingStatus(completion : @escaping (Result<ChargingStatusResponseModel, Error>) -> Void)
    func getFormattedTimeDifference(from dateString: String) -> String
    func registerForRemoteNotifications(fcmToken: String, completion : @escaping( Result<RemoteNotificationsResponse,Error>) -> Void)
}

class MapScreenViewModel: NSObject, MapScreenViewModelInterface {
    private let locationManager = CLLocationManager()
    weak var delegate: MapViewModelDelegate?
    var networkManager : NetworkManagerProtocol?


    init(networkManager : NetworkManagerProtocol) {
        self.networkManager = networkManager
        super.init()
        setUpLocation()
    }
    func fetchchargerLocation(lat : Double, lon : Double, range : Int,completion : @escaping (Result<ChargerRangeresponse,Error>) -> Void){
        let url = URLs.getChargerRange
        let mobile = UserDefaultManager.shared.getUserProfile()?.phoneNumber ?? ""
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        let body : [String: Any] = ["latitude" : lat,
                                       "longitude" : lon,
                                       "range" : range,
                                       "status" : "Active",
                                       "userPhone" : mobile]
        if let reqest = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(reqest, decodeTo: ChargerRangeresponse.self , completion: { [weak self] result in
                guard let _ = self else { return }
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
    func fetchLocationById(id : String,completion : @escaping (Result<ChargerLocationResponseById,Error>) -> Void){
        let url = URLs.getChargerById(chargerId: id)
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        if let reqest = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header){
            networkManager?.request(reqest, decodeTo: ChargerLocationResponseById.self , completion: { [weak self] result in
                guard let _ = self else { return }
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
}
extension MapScreenViewModel : CLLocationManagerDelegate{
    func setUpLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    // MARK: - Permission Check
    func isLocationPermissionGranted() -> Bool {
        let status = locationManager.authorizationStatus
        if status == .denied || status == .restricted {
            ToastManager.shared.showToast(message: "Please allow location access in settings")
        }
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }
    
    // MARK: - Request Permission (does NOT start updating)
    func requestLocationPermissionIfNeeded() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            ToastManager.shared.showToast(message: "Please allow location access in settings")
        default:
            break
        }
        locationManager.startUpdatingLocation()
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateUserLocation(location)
        locationManager.stopUpdatingLocation() // Stop after getting the location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
}
extension MapScreenViewModel {
    func fetchChargingStatus(completion : @escaping (Result<ChargingStatusResponseModel, Error>) -> Void){
        let url = URLs.getChargingStatusUrl
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        guard let phoneNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else { return }
        let body : [String:Any] = ["userPhone":phoneNumber,
                                   "timezone":"Asia/Kolkata"]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: ChargingStatusResponseModel.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
    func getFormattedTimeDifference(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current

        guard let pastDate = dateFormatter.date(from: dateString) else {
            return "Invalid date"
        }

        let currentDate = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: pastDate, to: currentDate)

        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0

        // Format with leading zeros
        let formatted = String(format: "%02d h : %02d m", hours, minutes)
        return formatted
    }
    func registerForRemoteNotifications(fcmToken: String, completion : @escaping( Result<RemoteNotificationsResponse,Error>) -> Void) {
        let url = URLs.pushNotificationUrl
        guard let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else { return }
        guard let authToken = UserDefaultManager.shared.getJWTToken() else { return }
        let header = ["Authorization": "Bearer \(authToken)"]
        let body = ["phoneNumber": mobileNumber, "fcmToken": fcmToken]
        if let request = networkManager?.createRequest(urlString: url, method: .post, body: body, encoding: .json, headers: header){
            networkManager?.request(request, decodeTo: RemoteNotificationsResponse.self) { [weak self] result in
                guard let _ = self else { return }
                completion(result)
            }
        }
    }
}
