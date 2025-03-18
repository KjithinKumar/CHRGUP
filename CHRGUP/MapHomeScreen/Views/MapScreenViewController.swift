//
//  MapScreenViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 10/03/25.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapScreenViewController: UIViewController {
    
    @IBOutlet weak var scanQRButton: UIButton!
    @IBOutlet weak var mapScreen: UIView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var locateButton: UIButton!
    
    var mapView : GMSMapView?
    var viewModel : MapScreenViewModelInterface?
    override func viewDidLoad() {
        GMSServices.provideAPIKey(AppIdentifications.GoolgeMaps.ApiKey)
        super.viewDidLoad()
        setUpMaps()
        setUpNavBar()
        viewModel?.delegate = self
        UserDefaultManager.shared.setLoginStatus(true)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        ToastManager.shared.showToast(message: "Welcome to CHRGUP")
    }
    
    func setUpMaps(){
        let camera = GMSCameraPosition.camera(withLatitude: 12.9716, longitude: 77.5946, zoom: 13)
        let options = GMSMapViewOptions()
        options.camera = camera
        mapView = GMSMapView.init(options: options)
        guard let mapView = mapView else {return}
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        do {
                if let styleURL = Bundle.main.url(forResource: "Mapstyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                }
        } catch {
            print("Failed to load map style: \(error)")
        }
        mapView.isMyLocationEnabled = true
        mapScreen.addSubview(mapView)
        mapScreen.addSubview(listButton)
        mapScreen.addSubview(locateButton)
        mapView.addSubview(scanQRButton)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
                mapView.topAnchor.constraint(equalTo: view.topAnchor),
                mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        listButton.backgroundColor = .black
        listButton.tintColor = ColorManager.textColor
        listButton.layer.cornerRadius = 10
        
        locateButton.backgroundColor = .black
        locateButton.tintColor = ColorManager.textColor
        locateButton.layer.cornerRadius = 10
        
        scanQRButton.layer.cornerRadius = 20
        scanQRButton.setTitle(AppStrings.Map.scanButtonTitle, for: .normal)
        scanQRButton.titleLabel?.font = FontManager.bold(size: 17)
        scanQRButton.imageView?.tintColor = ColorManager.backgroundColor
        scanQRButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        scanQRButton.backgroundColor = ColorManager.primaryColor
    }
    
    func setUpNavBar(){
        navigationController?.navigationBar.isHidden = false
        navigationController?.view.backgroundColor = ColorManager.secondaryBackgroundColor
        navigationController?.navigationBar.backgroundColor = ColorManager.secondaryBackgroundColor
        navigationController?.navigationBar.tintColor = ColorManager.textColor
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(listMenuTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchMenuTapped))
    }
    

    @objc func listMenuTapped(){
        let leftPopVc = SideMenuViewController()
        leftPopVc.viewModel = SideMenuViewModel()
        leftPopVc.delegate = self
        leftPopVc.modalPresentationStyle = .overFullScreen
        navigationController?.present(leftPopVc, animated: false)
    }
    @objc func searchMenuTapped(){
        
    }
    @IBAction func UpdateLocationButtonTapped(_ sender: Any) {
        viewModel?.requestLocationPermission()
    }
    @IBAction func listViewButtonTapped(_ sender: Any) {
    }
    
}
extension MapScreenViewController : MapViewModelDelegate {
    func didUpdateUserLocation(_ location: CLLocation) {
        let userLocation = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 13)
        guard let mapView = mapView else { return }
        mapView.animate(to: userLocation)
        let marker = GMSMarker(position: location.coordinate)
        marker.map = mapView
    }
    
    func didFailWithError(_ error: any Error) {
        debugPrint(error)
    }
    
    
}

extension MapScreenViewController : SideMenuDelegate {
    func didSelectMenuOption(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}
