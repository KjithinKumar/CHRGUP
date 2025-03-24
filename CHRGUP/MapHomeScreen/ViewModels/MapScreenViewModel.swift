//
//  MapScreenViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 12/03/25.
//

import Foundation
import CoreLocation

protocol MapViewModelDelegate: AnyObject {
    func didUpdateUserLocation(_ location: CLLocation)
    func didFailWithError(_ error: Error)
}
protocol MapScreenViewModelInterface{
    var delegate: MapViewModelDelegate? { get set }
    func requestLocationPermission()
}

class MapScreenViewModel: NSObject, CLLocationManagerDelegate, MapScreenViewModelInterface {
    private let locationManager = CLLocationManager()
    weak var delegate: MapViewModelDelegate?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
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
