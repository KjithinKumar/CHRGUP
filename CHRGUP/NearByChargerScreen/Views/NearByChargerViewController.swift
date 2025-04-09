//
//  NearByChargerViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 19/03/25.
//

import UIKit
import CoreLocation

class NearByChargerViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel : NearByChargerViewModelInterface?
    var userLocation : CLLocation?
    var isLoading : Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
        setUpTableView()
        if let lat = userLocation?.coordinate.latitude, let long = userLocation?.coordinate.longitude {
            if let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber{
                viewModel?.getNearByCharger(latitue: lat, longitude: long, range: 15, mobileNumber: mobileNumber){ [weak self] result in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch result{
                        case .success(let response):
                            if response.success{
                                self.isLoading = false
                                self.tableView.reloadData()
                            }else{
                                self.showAlert(title: "Error", message: response.message ?? "Something went wrong")
                            }
                        case .failure(let error):
                            AppErrorHandler.handle(error, in: self)
                        }
                    }
                }
            }
        }
    }
    
    func setUpUi() {
        view.backgroundColor = ColorManager.backgroundColor
        navigationItem.title = AppStrings.NearByCharger.Title
    }
}
extension NearByChargerViewController: UITableViewDataSource, UITableViewDelegate,locationInfoViewControllerDelegate {
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.register(UINib(nibName: "NearByChargerTableViewCell", bundle: nil), forCellReuseIdentifier:
                            NearByChargerTableViewCell.identifier)
        tableView.separatorStyle = .none
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 10 : viewModel?.nearByChargerData().count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NearByChargerTableViewCell.identifier) as? NearByChargerTableViewCell else { return UITableViewCell()}
        cell.backgroundColor = .clear
        if isLoading{
            cell.setShimmer(isShimmering: true)
            tableView.allowsSelection = false
        }else{
            cell.setShimmer(isShimmering: false)
            if let userLocation = userLocation{
                if let chargerLocation = viewModel?.sortedNearByChargerData(currentLocation: userLocation)[indexPath.row] {
                    cell.configure(viewModel: NearByChargerCellViewModel(chargerLocationData: chargerLocation),delegate: self)
                }
            }
            tableView.allowsSelection = true
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoVc = LocationInfoViewController()
        if let userLocation = userLocation{
            if let locationData = viewModel?.sortedNearByChargerData(currentLocation: userLocation)[indexPath.row]{
                infoVc.viewModel = LocationInfoViewModel(locationData: locationData,latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                infoVc.indexPath = indexPath
                infoVc.delegate = self
            }
        }
        self.present(infoVc, animated: true, completion: nil)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    func didTapFavouriteButton(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
extension NearByChargerViewController : NearByChargerViewModelDelegate {
    
}

extension NearByChargerViewController : NearByChargerTableViewCellDelegate {
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
