//
//  UserVehicleInfoViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 06/03/25.
//

import Foundation

protocol UserVehicleInfoViewModelDelegateProtocol : AnyObject{
    func didLoadVehicleData()
}
protocol UserVehicleInfoViewModelInterface {
    func loadVehicleData()
    func getFieldsForTableView() -> [UserVehicleInfoCellType]
    func getVariants(for type: String, make: String, model: String) -> [Variant]
    func getModels(for type: String, make: String) -> [String]
    func getMakes(for type: String) -> [String]
    func getVehicleTypes() -> [String]
}

class UserVehicleInfoViewModel : UserVehicleInfoViewModelInterface {
    weak var delegate : UserVehicleInfoViewModelDelegateProtocol?
    var networkManager: NetworkManagerProtocol?
    
    init(delegate: UserVehicleInfoViewModelDelegateProtocol, networkManager: NetworkManagerProtocol) {
        self.delegate = delegate
        self.networkManager = networkManager
    }
    var vehicleResponse: VehicleCatalogResponse?
    
    //Fetch Vehicle data for dropdown
    func loadVehicleData() {
        let url = URLs.vehiclesUrl
        if let request = networkManager?.createRequest(urlString: url, method: .get, body: nil, encoding: .json, headers: nil){
            networkManager?.request(request, decodeTo: VehicleCatalogResponse.self, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let vehicles) :
                    self.vehicleResponse = vehicles
                case .failure(let error):
                    debugPrint(error)
                }
            })
        }
        delegate?.didLoadVehicleData()
    }
    //fields that need to be displayed to the user
    func getFieldsForTableView() -> [UserVehicleInfoCellType]{
        let fields : [UserVehicleInfoCellType] = [
            .dropdown(dropdownType: .VehicleType,title: "Type", placeHolder: "Select Type"),
            .dropdown(dropdownType: .VehicleMake,title: "Make", placeHolder: "Select Make"),
            .dropdown(dropdownType: .VehicleModel,title: "Model", placeHolder: "Select Model"),
            .dropdown(dropdownType: .VehicleVariant,title: "Variant", placeHolder: "Select Vaiant"),
            .textField(title: "Vehicle Registration (Optional)", placeHolder: "Enter Vehicle Registration")
        ]
        return fields
    }
    // MARK: - Get Vehicle Types (3-Wheeler, 2-Wheeler)
        func getVehicleTypes() -> [String] {
            //guard let data = vehicleResponse?.data.first else { return [] }
            return ["3-Wheeler", "2-Wheeler"] // Returns ["3-Wheeler", "2-Wheeler"]
        }
        
        // MARK: - Get Makes for a Given Vehicle Type
        func getMakes(for type: String) -> [String] {
            guard let data = vehicleResponse?.data.first else { return [] }
            //guard let vehicleType = type else { return [] }
            
            switch type {
            case "3-Wheeler":
                return Array(data.threewheeler.keys)
            case "2-Wheeler":
                return Array(data.twowheeler.keys)
            default:
                return []
            }
        }
        
        // MARK: - Get Models for a Given Vehicle Type and Make
        func getModels(for type: String, make: String) -> [String] {
            guard let data = vehicleResponse?.data.first else { return [] }
            //guard let vehicleType = data[type] else { return [] }
            
            switch type {
            case "3-Wheeler":
                return data.threewheeler[make]?.keys.map { $0 } ?? []
            case "2-Wheeler":
                return data.twowheeler[make]?.keys.map { $0 } ?? []
            default:
                return []
            }
        }
        
        // MARK: - Get Variants for a Given Vehicle Type, Make, and Model
        func getVariants(for type: String, make: String, model: String) -> [Variant] {
            guard let data = vehicleResponse?.data.first else { return [] }
            //guard let vehicleType = data[type] else { return [] }
            
            switch type {
            case "3-Wheeler":
                return data.threewheeler[make]?[model] ?? []
            case "2-Wheeler":
                return data.twowheeler[make]?[model] ?? []
            default:
                return []
            }
        }
}
