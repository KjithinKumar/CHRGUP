//
//  UserVehicleInfoViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 06/03/25.
//

import UIKit

enum UserVehicleInfoScreenType{
    case registerNew   // First-time user registration with vehicle
    case addNew        // Adding a new vehicle to "My Garage"
    case edit          // Editing an existing vehicle
}

class UserVehicleInfoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    var viewModel : UserVehicleInfoViewModelInterface?
    
    var enabledFields: [UserVehicleInfoCellType: Bool] = [:]
    
    var userData : UserProfile?
    var userSelecetedVechileData : VehicleModel?
    var screenType : UserVehicleInfoScreenType = .registerNew

    private var selectedType: String?
    private var selectedMake: String?
    private var selectedModel: String?
    private var selectedVariant: String?
    private var registrationNumber: String?
    
    var isNextEnabled: Bool {
        return selectedType != nil &&
               selectedMake != nil &&
               selectedModel != nil &&
               selectedVariant != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTableView()
        viewModel?.loadVehicleData()
        observeKeyboardNotifications()
        initializeFieldStates()
        configureNextButton()
        
    }
    func configureNextButton() {
        if isNextEnabled {
            nextButton.backgroundColor = ColorManager.primaryColor
            nextButton.isEnabled = true
        }else{
            nextButton.backgroundColor = ColorManager.secondaryBackgroundColor
            nextButton.isEnabled = false
        }
    }
    deinit {
        removeKeyboardNotifications()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard let selectedType = selectedType,
              let selectedMake = selectedMake,
              let selectedModel = selectedModel,
              let selectedVariant = selectedVariant else {
            return
        }
        let variantDetails = viewModel?.getVariants(for: selectedType, make: selectedMake, model: selectedModel).first(where: { variant in
            variant.variant == selectedVariant
        })
        userSelecetedVechileData = VehicleModel(type: selectedType,
                                                    make: selectedMake,
                                                    model: selectedModel,
                                                    variant: selectedVariant,
                                                    vehicleReg: registrationNumber ?? "",
                                                    range: userSelecetedVechileData?.range ?? "",
                                                    id: userSelecetedVechileData?.id ?? "",
                                                    vehicleImg: variantDetails?.image ?? "" )
        guard let userSelecetedVechileData = userSelecetedVechileData else {
            return
        }
        
        
        let rangeVc = SetRangeViewController()
        userData?.userVehicle.insert(userSelecetedVechileData, at: 0)
        rangeVc.userData = userData
        rangeVc.selectedVehicleVariant = variantDetails
        rangeVc.setRangeScreenType = screenType
        rangeVc.viewModel = UserRegistrationViewModel(delegate: rangeVc, networkManager: NetworkManager())
        rangeVc.modalPresentationStyle = .popover
        switch screenType {
        case .registerNew:
            rangeVc.setRangeScreenType = .registerNew
        case .addNew:
            rangeVc.newVehicle = userSelecetedVechileData
            rangeVc.setRangeScreenType = .addNew
            rangeVc.delegate = self
        case .edit:
            rangeVc.newVehicle = userSelecetedVechileData
            rangeVc.setRangeScreenType = .edit
            rangeVc.delegate = self
        }
        present(rangeVc, animated: true)
    }
    
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        navigationController?.view.backgroundColor = ColorManager.secondaryBackgroundColor
        nextButton.titleLabel?.font = FontManager.bold(size: 20)
        nextButton.layer.cornerRadius = 20
        nextButton.backgroundColor = ColorManager.primaryColor
        nextButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
        
        
        switch screenType {
        case .registerNew:
            navigationItem.title = AppStrings.VehicleDetails.addVehicle
            nextButton.setTitle(AppStrings.VehicleDetails.addButtonTitle, for: .normal)
            navigationItem.backBarButtonItem?.isHidden = true
            configureNavBar()
        case .addNew:
            navigationItem.title = AppStrings.VehicleDetails.addVehicle
            nextButton.setTitle(AppStrings.VehicleDetails.addButtonTitle, for: .normal)
        case .edit:
            navigationItem.title = AppStrings.VehicleDetails.editVechicle
            nextButton.setTitle(AppStrings.VehicleDetails.updateButtonTitle, for: .normal)
            populateExistingVehicleData()
        }
    }
    func populateExistingVehicleData() {
        guard let vehicle = userSelecetedVechileData else { return }
        
        selectedType = vehicle.type
        selectedMake = vehicle.make
        selectedModel = vehicle.model
        selectedVariant = vehicle.variant
        registrationNumber = vehicle.vehicleReg
        
        enabledFields = [:]  // Enable all fields for editing
        for field in viewModel?.getFieldsForTableView() ?? [] {
            enabledFields[field] = true
        }
        tableView.reloadData()
    }
    func configureNavBar(){
        let button = UIButton(type: .system)
        let backImage = UIImage(systemName: "xmark")
        button.setImage(backImage, for: .normal)
        button.backgroundColor = .clear
        button.tintColor = ColorManager.buttonColorwhite
        button.contentHorizontalAlignment = .left
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
    }
    @objc func handleBackButton(){
        navigationController?.popToRootViewController(animated: true)
    }
    
}
extension UserVehicleInfoViewController: UITableViewDataSource{
    func setUpTableView(){
        tableView.dataSource = self
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.register(UINib(nibName: "DropdownTableViewCell", bundle: nil), forCellReuseIdentifier: DropdownTableViewCell.identifier)
        tableView.separatorColor = .clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getFieldsForTableView().count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = viewModel?.getFieldsForTableView()[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DropdownTableViewCell.identifier) as? DropdownTableViewCell else {
            fatalError("Could not dequeue cell")
        }
        guard let field = field else {return cell}
        var selectedValue: String? = nil
        let isEnabled = enabledFields[field] ?? false
        switch field {
        case .dropdown(let type ,_, _):
            switch type{
            case .VehicleType:
                selectedValue = selectedType
            case .VehicleMake:
                selectedValue = selectedMake
            case .VehicleModel:
                selectedValue = selectedModel
            case .VehicleVariant:
                selectedValue = selectedVariant
            }
        case .textField(_, _):
            selectedValue = registrationNumber
        }
        cell.configure(with: field, delegate: self, selectedValue: selectedValue,isEnabled: isEnabled)
        return cell
        
    }
}
extension UserVehicleInfoViewController : UserVehicleInfoViewModelDelegateProtocol{
    func didLoadVehicleData() {
        tableView.reloadData()
    }
}

extension UserVehicleInfoViewController : UserVehicleInfoCellDelegate{
    func getPickerData(for type: UserVehicleInfoCellType) -> [String] {
        switch type {
        case .dropdown(let type,_,_):
            switch type {
            case .VehicleType:
                return viewModel?.getVehicleTypes() ?? []
            case .VehicleMake:
                guard let selectedType = selectedType else {return []}
                return viewModel?.getMakes(for: selectedType) ?? []
            case .VehicleModel:
                guard let selectedType = selectedType, let selectedMake = selectedMake else {return []}
                return viewModel?.getModels(for: selectedType, make: selectedMake) ?? []
            case .VehicleVariant:
                guard let selectedType = selectedType,let selectedMake = selectedMake, let selectedModel = selectedModel else {return []}
                return viewModel?.getVariants(for: selectedType, make: selectedMake, model: selectedModel).map{$0.variant} ?? []
            }
        case .textField(_,_):
            return []
        }
    }
    
    func didSelectValue(_ value: String, for type: UserVehicleInfoCellType) {
        var rowsToReload : [IndexPath] = []
        switch type{
        case.dropdown(let type,_, _) :
            switch type{
            case .VehicleType:
                selectedType = value
                selectedMake = nil
                selectedModel = nil
                selectedVariant = nil
                resetEnabledFields(from: .VehicleMake)
                rowsToReload = [IndexPath(row: 1, section: 0),IndexPath(row: 2, section: 0),IndexPath(row: 3, section: 0),IndexPath(row: 4, section: 0)]
            case .VehicleMake:
                selectedMake = value
                selectedModel = nil
                selectedVariant = nil
                resetEnabledFields(from: .VehicleModel)
                rowsToReload = [IndexPath(row: 2, section: 0),IndexPath(row: 3, section: 0),IndexPath(row: 4, section: 0)]
            case .VehicleModel:
                selectedModel = value
                selectedVariant = nil
                resetEnabledFields(from: .VehicleVariant)
                rowsToReload = [IndexPath(row: 3, section: 0),IndexPath(row: 4, section: 0)]
            case .VehicleVariant:
                selectedVariant = value
                rowsToReload = [IndexPath(row: 4, section: 0)]
            }
        case .textField(_, _) :
            registrationNumber = value
        }
        tableView.reloadRows(at: rowsToReload,with : .none)
        configureNextButton()
  
    }
    func resetEnabledFields(from fieldType: DropdownType) {
        let fields = viewModel?.getFieldsForTableView() ?? []
        
        var disable = false
        for field in fields {
            if case .dropdown(let type, _, _) = field, type == fieldType {
                disable = true
            }
            if disable {
                enabledFields[field] = false
            }
        }
    }
    override func moveViewForKeyboard(yOffset: CGFloat) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -(yOffset - self.view.safeAreaInsets.bottom), right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        nextButton.transform = CGAffineTransform(translationX: 0, y: yOffset)
    }
    //After filling the first fields next fields should enable 
    func enableNextField(after type: UserVehicleInfoCellType) {
        guard let index = viewModel?.getFieldsForTableView().firstIndex(of: type) else { return }
        let fields = viewModel?.getFieldsForTableView() ?? []
        
        if index < fields.count - 1 {
            let nextField = fields[index + 1]
            enabledFields[nextField] = true
            tableView.reloadRows(at: [IndexPath(row: index + 1, section: 0)], with: .fade)
        }
    }
    func initializeFieldStates() {
        let fields = viewModel?.getFieldsForTableView() ?? []
        if screenType == .edit {
            // Enable all fields for editing
            for field in fields {
                enabledFields[field] = true
            }
        } else {
            // Enable only the first field for a new vehicle
            for (index, field) in fields.enumerated() {
                enabledFields[field] = (index == 0)
            }
        }
        tableView.reloadData()
    }
    
}
extension UserVehicleInfoViewController : setRangeViewControllerDelegate{
    
    func addedNewVehicle(message : String) {
        ToastManager.shared.showToast(message: message)
        view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            //self.dismissAlert()
            self.navigationController?.popViewController(animated: true)
        }
    }
    func failedToAddNewVehicle(_ error : String,_ code : Int) {
        if code == 401{
            let actions = [UIAlertAction(title: "Login Again", style: .default, handler: { alertAction in
                let welcomeVc = WelcomeViewController()
                welcomeVc.modalPresentationStyle = .fullScreen
                self.present(welcomeVc, animated: true)
            })]
            DispatchQueue.main.async {
                self.showAlert(title: "Unauthorized", message: error,actions: actions)
            }
        }else{
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: error)
            }
        }
    }
}
