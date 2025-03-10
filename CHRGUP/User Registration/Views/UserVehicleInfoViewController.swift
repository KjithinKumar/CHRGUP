//
//  UserVehicleInfoViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 06/03/25.
//

import UIKit

class UserVehicleInfoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    var viewModel : UserVehicleInfoViewModelInterface?
    
    var enabledFields: [UserVehicleInfoCellType: Bool] = [:]
    
    var userData : UserProfile?
    var userSelecetedVechileData : UserVehicleModel?

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
        configureNavBar()
        
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
        userSelecetedVechileData = UserVehicleModel(type: selectedType,
                                                    make: selectedMake,
                                                    model: selectedModel,
                                                    variant: selectedVariant,
                                                    vehicleReg: registrationNumber ?? "",
                                                    range: "",
                                                    id: "",
                                                    vehicleImg: variantDetails?.image ?? "" )
        guard let userSelecetedVechileData = userSelecetedVechileData else {
            return
        }
        userData?.userVehicle.insert(userSelecetedVechileData, at: 0)
        
        let vc = SetRangeViewController()
        vc.userData = userData
        vc.selectedVehicleVariant = variantDetails
        vc.viewModel = UserRegistrationViewModel(delegate: vc, networkManager: NetworkManager())
        vc.modalPresentationStyle = .popover
        present(vc, animated: true)
    }
    
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
       
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = FontManager.bold(size: 20)
        
        nextButton.layer.cornerRadius = 20
        nextButton.backgroundColor = ColorManager.primaryColor
        nextButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
        
        navigationItem.backBarButtonItem?.isHidden = true
    }
    func configureNavBar(){
        let button = UIButton(type: .system)
       let backImage = UIImage(systemName: "xmark")
        //?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(weight: .bold))
        button.setImage(backImage, for: .normal)
        button.backgroundColor = .clear
        button.tintColor = ColorManager.buttonColorwhite
        button.contentHorizontalAlignment = .left
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        navigationItem.title = "Vehicle Info"
        
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
    
    func didSaveVehicleInfoSuccessfully() {
        debugPrint("saved")
    }
    
    func didFailToSaveVehicleInfo(error: String) {
        debugPrint("failed to save")
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
        //tableView.transform = CGAffineTransform(translationX: 0, y: yOffset)
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
        for (index, field) in fields.enumerated() {
            enabledFields[field] = (index == 0) // Enable only first field initially
        }
        tableView.reloadData()
    }
    
}
