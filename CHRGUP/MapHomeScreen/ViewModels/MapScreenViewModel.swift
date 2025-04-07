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
    func requestLocationPermission()
    func fetchchargerLocation(lat : Double, lon : Double, range : Int,completion : @escaping (Result<ChargerRangeresponse,Error>) -> Void)
    func fetchLocationById(id : String,completion : @escaping (Result<ChargerLocationResponseById,Error>) -> Void)
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
            networkManager?.request(reqest, decodeTo: ChargerRangeresponse.self , completion: { result in
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
            networkManager?.request(reqest, decodeTo: ChargerLocationResponseById.self , completion: { result in
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
    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }else if status == .denied || status == .restricted {
            ToastManager.shared.showToast(message: "Please allow location access in settings")
        }
        else {
            locationManager.startUpdatingLocation()
        }
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
