//
//  UserVehicleInfoViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 06/03/25.
//

import Foundation

protocol UserVehicleInfoViewModelDelegateProtocol : AnyObject{
    func didLoadVehicleData()
    func didFailtoLoadVehicleData(error: Error)
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
                    delegate?.didFailtoLoadVehicleData(error: error)
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
    // MARK: - Get Vehicle Types
    func getVehicleTypes() -> [String] {
        guard let data = vehicleResponse?.data.first else { return [] }
        return Array(data.keys)
    }
    // MARK: - Get Makes for a Given Vehicle Type
    func getMakes(for type: String) -> [String] {
        guard let data = vehicleResponse?.data.first,
              let makeDict = data[type] else { return [] }
        return Array(makeDict.keys)
    }
    // MARK: - Get Models for a Given Vehicle Type and Make
    func getModels(for type: String, make: String) -> [String] {
        guard let data = vehicleResponse?.data.first,
              let makeDict = data[type],
              let modelDict = makeDict[make] else { return [] }
        return Array(modelDict.keys)
    }
    // MARK: - Get Variants for a Given Vehicle Type, Make, and Model
    func getVariants(for type: String, make: String, model: String) -> [Variant] {
        guard let data = vehicleResponse?.data.first,
              let variants = data[type]?[make]?[model] else { return [] }
        return variants
    }
}
