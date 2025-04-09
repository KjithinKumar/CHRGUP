//
//  MapScreenViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 10/03/25.
//

import UIKit
import GoogleMaps
import CoreLocation
import GoogleMapsUtils

class MapScreenViewController: UIViewController{
    
    @IBOutlet weak var scanQRButton: UIButton!
    @IBOutlet weak var mapScreen: UIView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var buttonButtomConstraint: NSLayoutConstraint!
    
    private var userLocation : CLLocation?
    var mapView : GMSMapView?
    var viewModel : MapScreenViewModelInterface?
    var clusterManager : GMUClusterManager?
    private var didTapCluster = false
    private var lastFetchedChargers: [ChargerRangeModel] = []
    private var bottomCardConstraint: NSLayoutConstraint!
    private var chargerDetailContainer: UIView!
    private var chargerDetailTableView: UITableView!
    private var selectedCharger: ChargerLocation?
    private var isLoading = true
    
    override func viewDidLoad() {
        GMSServices.provideAPIKey(AppIdentifications.GoolgeMaps.ApiKey)
        super.viewDidLoad()
        setUpMaps()
        setUpNavBar()
        viewModel?.delegate = self
        UserDefaultManager.shared.setLoginStatus(true)
        viewModel?.requestLocationPermission()
        setupUI()
        setupBottomCard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        selectedCharger = nil
        clusterManager?.cluster()
        hideBottomCard()
        if let mapView = mapView {
            let position = mapView.camera
            let centerLat = position.target.latitude
            let centerLng = position.target.longitude
            let visibleRadius = getVisibleRadius(from: mapView)
            setUplocation(latitude: centerLat, longitude: centerLng, range: visibleRadius)
        }
    }
    func setupUI(){
        listButton.backgroundColor = .black
        listButton.tintColor = ColorManager.textColor
        listButton.layer.cornerRadius = 10
        
        locateButton.backgroundColor = .black
        locateButton.tintColor = ColorManager.textColor
        locateButton.layer.cornerRadius = 10
        
        scanQRButton.layer.cornerRadius = 25
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(leftMenuTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchMenuTapped))
    }
    @IBAction func scanQRButtonPressed(_ sender: Any) {
        let scanVc = ScanQrViewController()
        scanVc.viewModel = ScanQrViewModel(networkManager: NetworkManager())
        scanVc.onCodeScanned = { [weak self] (data,payload) in
            guard let self = self else { return }
            scanVc.dismiss(animated: true) {
                let startChargeVc = StartChargeViewController()
                startChargeVc.modalPresentationStyle = .fullScreen
                startChargeVc.viewModel = StartChargeViewModel(chargerInfo: data, networkManager: NetworkManager())
                startChargeVc.payLoad = payload
                self.navigationController?.present(startChargeVc, animated: true)
            }
        }
        scanVc.modalPresentationStyle = .fullScreen
        navigationController?.present(scanVc, animated: true)
    }
    
    @objc func leftMenuTapped(){
        let leftPopVc = SideMenuViewController()
        leftPopVc.viewModel = SideMenuViewModel(networkManager: NetworkManager(),delegate: leftPopVc)
        leftPopVc.delegate = self
        leftPopVc.modalPresentationStyle = .overFullScreen
        navigationController?.present(leftPopVc, animated: false)
    }
    @objc func searchMenuTapped(){
        let searchVc = SearchViewController()
        searchVc.viewModel = SearchViewModel(networkManager: NetworkManager())
        navigationController?.pushViewController(searchVc, animated: true)
        
    }
    @IBAction func UpdateLocationButtonTapped(_ sender: Any) {
        viewModel?.requestLocationPermission()
    }
    @IBAction func listViewButtonTapped(_ sender: Any) {
        let listViewVc = NearByChargerViewController()
        listViewVc.userLocation = userLocation
        listViewVc.viewModel = NearByChargerViewModel(networkManager: NetworkManager(),delegate: listViewVc)
        navigationController?.pushViewController(listViewVc, animated: true)
    }
    
}

//MARK: - MapviewDelegate,ClusterManagerDelegate
extension MapScreenViewController : GMSMapViewDelegate, GMUClusterManagerDelegate  {
    func setUpMaps(){
        let camera = GMSCameraPosition.camera(withLatitude: 12.9716, longitude: 77.5946, zoom: 14)
        let options = GMSMapViewOptions()
        options.camera = camera
        mapView = GMSMapView.init(options: options)
        mapView?.delegate = self
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
        
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [200], backgroundColors: [ColorManager.primaryColor])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        renderer.delegate = self
        clusterManager?.setDelegate(self, mapDelegate: self)
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if didTapCluster {
            didTapCluster = false
            return
        }
        let centerLat = position.target.latitude
        let centerLng = position.target.longitude
        let visibleRadius = getVisibleRadius(from: mapView)
        setUplocation(latitude: centerLat, longitude: centerLng, range: visibleRadius)
    }
    private func getVisibleRadius(from mapView: GMSMapView) -> Int {
        let center = mapView.camera.target
        let topCenter = mapView.projection.coordinate(for: CGPoint(x: mapView.frame.width / 2, y: 0))
        
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let topCenterLocation = CLLocation(latitude: topCenter.latitude, longitude: topCenter.longitude)

        let distanceInMeters = centerLocation.distance(from: topCenterLocation)
        return Int(distanceInMeters / 1000) // convert to kilometers if needed
    }
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        didTapCluster = true
        mapView?.animate(with: GMSCameraUpdate.setTarget(cluster.position, zoom: 14))
        return true
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let clusterItem = marker.userData as? ChargerClusterItem{
            if clusterItem.chargers?.id != selectedCharger?.id{
                hideBottomCard()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.showBottomCard()
                self.chargerDetailTableView.reloadData()
            }
            if let icon = self.markerIcon(for: clusterItem.chargers?.chargerInfo) {
                marker.icon = self.resizeMarkerImage(image: icon, scale: 1.3)
                self.selectedCharger = nil
                self.clusterManager?.cluster()
            }
            
            viewModel?.fetchLocationById(id: clusterItem.chargers?.id ?? "") { [weak self]result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case.success(let response):
                        if response.success {
                            if let chargerData = response.data {
                                self.selectedCharger = chargerData
                                self.isLoading = false
                                self.chargerDetailTableView.reloadData()
                                self.clusterManager?.cluster()
                            }else{
                                self.showAlert(title: "Error", message: response.message ?? "Something went wrong")
                            }
                        }
                    case.failure(let error):
                        AppErrorHandler.handle(error, in: self)
                    }
                }
            }
        }
        return false
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideBottomCard()
        selectedCharger = nil
        clusterManager?.cluster()
    }
    
}

//MARK: - MapViewModelDelegate
extension MapScreenViewController : MapViewModelDelegate {
    func didUpdateUserLocation(_ location: CLLocation) {
        let userLocation = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 14)
        UserDefaultManager.shared.saveUserCurrentLocation(location.coordinate.latitude, location.coordinate.longitude)
        self.userLocation = location
        guard let mapView = mapView else { return }
        mapView.animate(to: userLocation)
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

//MARK: - Map Icons
extension MapScreenViewController {
    func setUplocation(latitude : Double, longitude : Double, range : Int){
        viewModel?.fetchchargerLocation(lat: latitude, lon: longitude, range: range) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result{
                case .success(let response):
                    if response.success{
                        if let chargerLocations = response.data{
                            if self.areChargersDifferent(old: self.lastFetchedChargers, new: chargerLocations) {
                                   self.lastFetchedChargers = chargerLocations
                                   self.updateMapWithChargers(chargerLocations)
                            }
                        }
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
    func updateMapWithChargers(_ chargers: [ChargerRangeModel]) {
        clusterManager?.clearItems()
        for charger in chargers {
            if let lat = charger.direction?.latitude,
               let lon = charger.direction?.longitude {
                let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let item = ChargerClusterItem(position: position, chargers: charger)
                clusterManager?.add(item)
            }
        }
        
        clusterManager?.cluster()
    }
    func areChargersDifferent(old: [ChargerRangeModel], new: [ChargerRangeModel]) -> Bool {
        guard old.count == new.count else { return true }
        
        for (index, charger) in old.enumerated() {
            guard let oldLat = charger.direction?.latitude,
                  let oldLon = charger.direction?.longitude,
                  let newLat = new[index].direction?.latitude,
                  let newLon = new[index].direction?.longitude,
                  charger.id == new[index].id else {
                return true
            }
            
            if abs(oldLat - newLat) > 0.0001 || abs(oldLon - newLon) > 0.0001 {
                return true
            }
        }
        
        return false
    }
    
    
    func markerIcon(for chargers: [ChargerInfo]?) -> UIImage? {
        guard let chargers = chargers else { return UIImage(named: "Location inactive") }
        
        let available = chargers.filter { $0.status == "Available" }.count
        let inUse = chargers.filter { $0.status != "Available" && $0.status != "Inactive" }.count
        let inactive = chargers.filter { $0.status == "Inactive" }.count
        
        if available > 0 {
            return UIImage(named: "Location available")
        } else if inUse > 0 {
            return UIImage(named: "Location inuse")
        } else if inactive > 0 {
            return UIImage(named: "Location inactive")
        } else {
            return UIImage(named: "Location inactive")
        }
    }
    func resizeMarkerImage(image: UIImage, scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
}

extension MapScreenViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let clusterItem = marker.userData as? ChargerClusterItem {
            if let image = markerIcon(for: clusterItem.chargers?.chargerInfo){
                if clusterItem.chargers?.id == selectedCharger?.id {
                    marker.icon = resizeMarkerImage(image: image, scale: 1.3)
                } else {
                    marker.icon = image
                }
            }
        }
    }
}

extension MapScreenViewController : UITableViewDelegate,UITableViewDataSource {
    
    func setupBottomCard() {
        chargerDetailContainer = UIView()
        chargerDetailContainer.backgroundColor = ColorManager.secondaryBackgroundColor
        chargerDetailContainer.layer.cornerRadius = 20
        chargerDetailContainer.clipsToBounds = true
        chargerDetailContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chargerDetailContainer)
        
        chargerDetailTableView = UITableView()
        chargerDetailTableView.translatesAutoresizingMaskIntoConstraints = false
        chargerDetailContainer.addSubview(chargerDetailTableView)
        
        chargerDetailTableView.register(UINib(nibName: "NearByChargerTableViewCell", bundle: nil), forCellReuseIdentifier: NearByChargerTableViewCell.identifier)
        chargerDetailTableView.dataSource = self
        chargerDetailTableView.delegate = self
        chargerDetailTableView.rowHeight = UITableView.automaticDimension
        chargerDetailTableView.estimatedRowHeight = 250
        chargerDetailTableView.isScrollEnabled = false
       
        
        bottomCardConstraint = chargerDetailContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 250)
        
        NSLayoutConstraint.activate([
            chargerDetailContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            chargerDetailContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            bottomCardConstraint,
            chargerDetailContainer.heightAnchor.constraint(equalToConstant: 250),
            
            chargerDetailTableView.topAnchor.constraint(equalTo: chargerDetailContainer.topAnchor),
            chargerDetailTableView.bottomAnchor.constraint(equalTo: chargerDetailContainer.bottomAnchor),
            chargerDetailTableView.leadingAnchor.constraint(equalTo: chargerDetailContainer.leadingAnchor,constant: -10),
            chargerDetailTableView.trailingAnchor.constraint(equalTo: chargerDetailContainer.trailingAnchor,constant: 10),
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NearByChargerTableViewCell.identifier) as? NearByChargerTableViewCell else { return UITableViewCell()}
        cell.backgroundColor = ColorManager.secondaryBackgroundColor
        if isLoading{
            cell.setShimmer(isShimmering: true)
            tableView.allowsSelection = false
        }else{
            cell.setShimmer(isShimmering: false)
            if let userLocation = self.userLocation{
                if let chargerLocation = selectedCharger {
                    let modchargerLocation = ChargerLocationProcessor.process(chargerLocation, currentLocation: userLocation)
                    cell.configure(viewModel: NearByChargerCellViewModel(chargerLocationData: modchargerLocation),delegate: self)
                }
                tableView.allowsSelection = true
            }
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoVc = LocationInfoViewController()
        if let userLocation = userLocation{
            if let locationData = selectedCharger{
                let modLocationData = ChargerLocationProcessor.process(locationData, currentLocation: userLocation)
                infoVc.viewModel = LocationInfoViewModel(locationData: modLocationData,latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                infoVc.indexPath = indexPath
                infoVc.delegate = self
            }
        }
        self.present(infoVc, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func showBottomCard() {
        bottomCardConstraint.constant = -30
        buttonButtomConstraint.constant = 265
        UIView.animate() {
            self.view.layoutIfNeeded()
        }
    }

    func hideBottomCard() {
        bottomCardConstraint.constant = 250
        buttonButtomConstraint.constant = 15
        UIView.animate() {
            self.view.layoutIfNeeded()
        }
        isLoading = true
    }
}
extension MapScreenViewController : NearByChargerTableViewCellDelegate{
    func addedTofavouriteResponse(response: FavouriteResponseModel?, error: (any Error)?) {
        if let error = error {
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
        if let response = response {
            if !response.status{
                DispatchQueue.main.async {
                    self.showAlert(title: "Failed to add", message: response.message)
                }
            }else{
                DispatchQueue.main.async {
                    ToastManager.shared.showToast(message: response.message ?? "Location added to favourite")
                }
            }
        }
    }
}
extension MapScreenViewController : locationInfoViewControllerDelegate {
    func didTapFavouriteButton(at indexPath: IndexPath) {
        chargerDetailTableView.reloadData()
    }
}
