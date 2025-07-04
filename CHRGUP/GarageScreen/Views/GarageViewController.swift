//
//  GarageViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 12/03/25.
//

import UIKit

class GarageViewController: UIViewController {

    @IBOutlet weak var addnewButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel : GarageViewModelInterface?
    private var isLoading = true
    private var deletedVehicleId : String?
    private var deletingVehicleIndexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.fetchVehicles()
    }
    @IBAction func addNewButtonPressed(_ sender: Any) {
        let vehicleVc = UserVehicleInfoViewController()
        vehicleVc.viewModel = UserVehicleInfoViewModel(delegate: vehicleVc, networkManager: NetworkManager())
        vehicleVc.userData = UserDefaultManager.shared.getUserProfile()
        vehicleVc.screenType = .addNew
        navigationController?.pushViewController(vehicleVc, animated: true)
    }
    func configureUi() {
        navigationItem.title = AppStrings.Garage.Title
        navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = ColorManager.secondaryBackgroundColor
        addnewButton.layer.cornerRadius = addnewButton.frame.height/2
        addnewButton.layer.masksToBounds = true
        addnewButton.backgroundColor = ColorManager.primaryColor
        addnewButton.tintColor = ColorManager.buttonTextColor
        addnewButton.isHidden = isLoading
    }

}

extension GarageViewController: UITableViewDataSource, UITableViewDelegate {
    func configureTableView() {
        tableView.register(UINib(nibName: "GarageTableViewCell", bundle: nil), forCellReuseIdentifier: GarageTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = ColorManager.backgroundColor
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 5 : viewModel?.getVehicles()?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GarageTableViewCell.reuseIdentifier) as? GarageTableViewCell else {
            fatalError("Could not dequeue GarageTableViewCell")
        }
        if isLoading{
            cell.setShimmering(true)
        }else{
            if let vehicle = viewModel?.getVehicles(){
                cell.setShimmering(false)
                cell.configure(with: vehicle[indexPath.row], delegate: self,indexPath: indexPath)
            }
        }
        cell.backgroundColor = ColorManager.backgroundColor
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}
extension GarageViewController: GarageViewModelDelegate {
    func receivedVehicleDetails() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.tableView.reloadData()
            self.addnewButton.isHidden = self.isLoading
        }
        if self.deletedVehicleId != nil{
            self.updateUserDefaultSelectedVehicle()
        }
    }
    
    func didUpdateGarage(_ vehicle: VehicleModel) {

    }
    func didDeletedVehicle(_ message : String) {
        DispatchQueue.main.async {
            self.tableView.performBatchUpdates {
                if let deletingVehicleIndexPath = self.deletingVehicleIndexPath{
                    self.viewModel?.userVehicles?.remove(at: deletingVehicleIndexPath.row)
                    self.tableView.deleteRows(at: [deletingVehicleIndexPath], with: .left)
                }
            } completion: { _ in
                ToastManager.shared.showToast(message: message)
                self.viewModel?.fetchVehicles()
            }
        }
    }
    
    func didFailWithError(_ error: String, _ code: Int) {
        if code == 401{
            let actions = [AlertActions.loginAgainAction()]
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

extension GarageViewController : GarageTableViewCellDelegate{
    func didTapEdit(at index: Int) {
        let editingVechile = viewModel?.getVehicles()?[index]
        let vehicleInfoVc = UserVehicleInfoViewController()
        vehicleInfoVc.modalPresentationStyle = .fullScreen
        vehicleInfoVc.viewModel = UserVehicleInfoViewModel(delegate: vehicleInfoVc, networkManager: NetworkManager())
        vehicleInfoVc.screenType = .edit
        vehicleInfoVc.userSelecetedVechileData = editingVechile
        navigationController?.pushViewController(vehicleInfoVc, animated: true)
        
    }
    
    func didTapDelete(at index: Int) {
        let deletingVechicle = viewModel?.getVehicles()?[index]
        self.deletingVehicleIndexPath = IndexPath(row: index, section: 0)
        let userSlectedVechile = UserDefaultManager.shared.getSelectedVehicle()
        guard let make = deletingVechicle?.make, let model = deletingVechicle?.model, let variant = deletingVechicle?.variant else { return }
        let vehicleName = "\(make) \(model) \(variant)"
        let alertVc = CustomDeleteAlertController(vehicleImageURL: URLs.imageUrl(deletingVechicle?.vehicleImg ?? ""), vehicleName: vehicleName) {
            guard let deletingVehicleId = self.viewModel?.getVehicles()?[index].id else{ return}
            self.viewModel?.deleteVehicle(vehicleId: deletingVehicleId)
            if deletingVehicleId == userSlectedVechile?.id{
                self.deletedVehicleId = deletingVehicleId
            }
        }
        present(alertVc, animated: true)
        
    }
    func updateUserDefaultSelectedVehicle(){
        let nextSelectedVehicle = viewModel?.getVehicles()?[0]
        UserDefaultManager.shared.saveSelectedVehicle(nextSelectedVehicle)
    }
}
