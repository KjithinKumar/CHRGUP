//
//  ReservationViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 02/06/25.
//

import UIKit
import CoreLocation
import Lottie

class ReservationViewController: UIViewController {
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var reservedButton: UIButton!
    @IBOutlet weak var failedButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private var animationView: LottieAnimationView?
    var userLocation : CLLocation?
    var isLoading : Bool = true
    var viewModel : ReservationViewModelInterface?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTableView()
        configureButtonState(uiButton: allButton)
        fetchData()
        setupLottieAnimation()
        animationView?.isHidden = true
    }
    @IBAction func allButtonPressed(_ sender: Any) {
        configureButtonState(uiButton: allButton)
        viewModel?.currentFilter = .all
    }
    @IBAction func completedButtonPressed(_ sender: Any) {
        configureButtonState(uiButton: completedButton)
        viewModel?.currentFilter = .completed
    }
    @IBAction func reservedButtonPressed(_ sender: Any) {
        configureButtonState(uiButton: reservedButton)
        viewModel?.currentFilter = .reserved
    }
    @IBAction func failedButtonPressed(_ sender: Any) {
        configureButtonState(uiButton: failedButton)
        viewModel?.currentFilter = .failed
    }
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        
        navigationItem.title = AppStrings.reserveCharger.reservationTitleText
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(navigateToNearBy))
        
        allButton.layer.cornerRadius = 10
        allButton.layer.masksToBounds = true
        allButton.setTitle(AppStrings.reserveCharger.allButtonText, for: .normal)
        allButton.backgroundColor = ColorManager.secondaryBackgroundColor
        allButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
        allButton.titleLabel?.font = FontManager.light()
        allButton.layer.borderColor = ColorManager.textColor.cgColor
        
        completedButton.layer.cornerRadius = 10
        completedButton.layer.masksToBounds = true
        completedButton.setTitle(AppStrings.reserveCharger.completedButtonText, for: .normal)
        completedButton.backgroundColor = ColorManager.secondaryBackgroundColor
        completedButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
        completedButton.setImage(UIImage(named: "GreenDot"), for: .normal)
        completedButton.titleLabel?.font = FontManager.light()
        completedButton.layer.borderColor = ColorManager.completedColor.cgColor
        
        reservedButton.layer.cornerRadius = 10
        reservedButton.layer.masksToBounds = true
        reservedButton.setTitle(AppStrings.reserveCharger.reservedButtonText, for: .normal)
        reservedButton.backgroundColor = ColorManager.secondaryBackgroundColor
        reservedButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
        reservedButton.setImage(UIImage(named: "BlueDot"), for: .normal)
        reservedButton.titleLabel?.font = FontManager.light()
        reservedButton.layer.borderColor = ColorManager.reservedColor.cgColor
        
        failedButton.layer.cornerRadius = 10
        failedButton.layer.masksToBounds = true
        failedButton.setTitle(AppStrings.reserveCharger.failedButtonText, for: .normal)
        failedButton.backgroundColor = ColorManager.secondaryBackgroundColor
        failedButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
        failedButton.setImage(UIImage(named: "RedDot"), for: .normal)
        failedButton.titleLabel?.font = FontManager.light()
        failedButton.layer.borderColor = ColorManager.cancelledColor.cgColor
    }
    @objc func navigateToNearBy(){
        if let location = UserDefaultManager.shared.getUserCurrentLocation(){
            userLocation = CLLocation(latitude: location.first!, longitude: location.last!)
        }
        let listViewVc = NearByChargerViewController()
        listViewVc.reloadReservation = { [weak self] in
            guard let self = self else { return }
            self.fetchData()
        }
        listViewVc.userLocation = userLocation
        listViewVc.viewModel = NearByChargerViewModel(networkManager: NetworkManager())
        navigationController?.pushViewController(listViewVc, animated: true)
    }
    func configureButtonState(uiButton: UIButton){
        if uiButton == allButton{
            completedButton.layer.borderWidth = 0
            reservedButton.layer.borderWidth = 0
            failedButton.layer.borderWidth = 0
            allButton.layer.borderWidth = 1
        }else if uiButton == completedButton{
            allButton.layer.borderWidth = 0
            reservedButton.layer.borderWidth = 0
            failedButton.layer.borderWidth = 0
            completedButton.layer.borderWidth = 1
        }else if uiButton == reservedButton{
            completedButton.layer.borderWidth = 0
            allButton.layer.borderWidth = 0
            failedButton.layer.borderWidth = 0
            reservedButton.layer.borderWidth = 1
        }else if uiButton == failedButton{
            completedButton.layer.borderWidth = 0
            reservedButton.layer.borderWidth = 0
            allButton.layer.borderWidth = 0
            failedButton.layer.borderWidth = 1
        }
    }
    func fetchData(){
        self.isLoading = true
        viewModel?.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.tableView.reloadData()
                self?.checkForEmptyState()
            }
        }
        Task{
            do{
                if let response = try await self.viewModel?.fetchReservations(){
                    if response.status{
                        isLoading = false
                        tableView.reloadData()
                    }else{
                        debugPrint(response.message)
                    }
                }
            }catch(let error){
                AppErrorHandler.handle(error,in: self)
            }
            checkForEmptyState()
        }
        
    }
    func setupLottieAnimation() {
        animationView = LottieAnimationView(name: "no_data_anim")
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
        animationView?.play()
        
        view.addSubview(animationView!)
        NSLayoutConstraint.activate([
            animationView!.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: 10),
            animationView!.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -50),
                animationView!.widthAnchor.constraint(equalToConstant: 300),
                animationView!.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
       
    func checkForEmptyState() {
        if viewModel?.filteredReservations.count == 0 {
            tableView.isHidden = true
            animationView?.isHidden = false
        } else {
            tableView.isHidden = false
            animationView?.isHidden = true
        }
    }
}

extension ReservationViewController: UITableViewDataSource, UITableViewDelegate{
    func setUpTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.register(UINib(nibName: "ReservationTableViewCell", bundle: nil), forCellReuseIdentifier: ReservationTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 10 : viewModel?.filteredReservations.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReservationTableViewCell.identifier) as? ReservationTableViewCell else { return UITableViewCell() }
        if isLoading{
            cell.setShimmering(isShimmer: isLoading)
        }else {
            cell.setShimmering(isShimmer: false)
            if let reservations = viewModel?.filteredReservations[indexPath.row]{
                cell.configure(reservation:reservations, delegate: self)
            }
        }
        cell.backgroundColor = ColorManager.backgroundColor
        return cell
    }
}
extension ReservationViewController: ReservationTableViewCellDelegate{
    func didTapCancelButton(for cell: ReservationTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let cancelAction = UIAlertAction(title: "No", style: .default)
        let okAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self else {return}
            Task {
                do {
                    if let response = try await self.viewModel?.cancelReservation(at: indexPath.row){
                        if response.status{
                            ToastManager.shared.showToast(message: response.message)
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }else{
                            debugPrint(response.message)
                        }
                    }
                }catch(let error){
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
        if let time = cell.reservationTime{
            showAlert(title: "Cancel Reservation?", message: time,actions: [cancelAction,okAction])
        }
    }
    
}
