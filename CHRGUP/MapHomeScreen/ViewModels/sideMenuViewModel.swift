//
//  sideMenuViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/03/25.
//

import Foundation

struct SideMenuItem {
    let title: String
    let icon: String
    let sideMenuDestiantion : sideMenuDestination
}
enum sideMenuDestination{
    case mygarage
    case favouritedocks
    case history
    case helpandsupport
    case settings
    case reservations
}

protocol sideMenuDelegate : AnyObject{
    func receivedVehicleDetails()
    func didFailWithError(_ message : String,_ code : Int)
}

protocol SideMenuViewModelInterface {
    var sideMenuItems: [SideMenuItem] { get }
    func fetchVehicleDetails()
    var vehicleData : [VehicleModel]? { get set }
    
}

class SideMenuViewModel: SideMenuViewModelInterface {
    let sideMenuItems = [
        SideMenuItem(title: AppStrings.leftMenu.MyGarage, icon: AppStrings.leftMenu.GarageImage,sideMenuDestiantion: .mygarage),
        SideMenuItem(title: AppStrings.leftMenu.Reservation, icon: AppStrings.leftMenu.ReservationImage, sideMenuDestiantion: .reservations),
        SideMenuItem(title: AppStrings.leftMenu.FavouriteDocks, icon: AppStrings.leftMenu.FavouriteDockImage,sideMenuDestiantion: .favouritedocks),
        SideMenuItem(title: AppStrings.leftMenu.History, icon: AppStrings.leftMenu.HistoryImage,sideMenuDestiantion: .history),
        SideMenuItem(title: AppStrings.leftMenu.HelpandSupport, icon: AppStrings.leftMenu.HelpandSupportImage,sideMenuDestiantion: .helpandsupport),
        SideMenuItem(title: AppStrings.leftMenu.Settings, icon: AppStrings.leftMenu.SettingsImage,sideMenuDestiantion: .settings),
    ]
    var userData : UserProfile?
    var vehicleData : [VehicleModel]?
    var authToken : String?
    var mobileNumber : String?
    var networkManager : NetworkManagerProtocol?
    weak var delegate : sideMenuDelegate?
    
    func fetchUserDetails() {
        userData = UserDefaultManager.shared.getUserProfile()
        vehicleData = UserDefaultManager.shared.getUserProfile()?.userVehicle
        authToken = UserDefaultManager.shared.getJWTToken()
        mobileNumber = userData?.phoneNumber
    }
    init(networkManager: NetworkManagerProtocol, delegate: sideMenuDelegate) {
        self.networkManager = networkManager
        self.delegate = delegate
        self.fetchUserDetails()
    }
    
    func fetchVehicleDetails() {
        guard let mobileNumber = mobileNumber, let authToken = authToken else {
            return
        }
        let url = URLs.userVehiclesUrl(mobileNumber: mobileNumber)
        let header = ["Authorization": "Bearer \(authToken)"]
        let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: header)
        if let request = request {
            networkManager?.request(request, decodeTo: UserVehicleResponse.self, completion: { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .success(let response) :
                    self.vehicleData = response.data
                    self.delegate?.receivedVehicleDetails()
                case .failure(let error):
                    if let error = error as? NetworkManagerError{
                        switch error{
                        case .serverError(let message,let code) :
                            self.delegate?.didFailWithError(message,code)
                        default :
                            break
                        }
                    }
                    debugPrint(error)
                }
            })
        }
    }
}


