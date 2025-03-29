//
//  FavouriteDockViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 27/03/25.
//

import UIKit
import Lottie

class FavouriteDockViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel : FavouriteDockViewModelInterface?
    var isLoading : Bool = true
    private var animationView: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTableView()
        DispatchQueue.main.async {
            self.fetchData()
        }
        
    }
    func setUpUI(){
        navigationItem.title = "Favourite Docks"
        view.backgroundColor = ColorManager.backgroundColor
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
        if viewModel?.favouriteLocation?.count == 0 {
            tableView.isHidden = true
            animationView?.isHidden = false
        } else {
            tableView.isHidden = false
            animationView?.isHidden = true
        }
    }
    func fetchData(){
        viewModel?.getUserFavouriteLocation(completion: { result in
            switch result{
            case .success(let response):
                if response.status{
                    self.isLoading = false
                    DispatchQueue.main.async {
                        self.setupLottieAnimation()
                        self.checkForEmptyState()
                        self.tableView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: response.message ?? "Something went wrong")
                    }
                }

            case .failure(let error):
                if let error = error as? NetworkManagerError{
                    switch error{
                    case .serverError(let message,let code) :
                        if code == 401{
                            let actions = [AlertActions.loginAgainAction()]
                            DispatchQueue.main.async {
                                self.showAlert(title: "Unauthorized", message: message,actions: actions)
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.showAlert(title: "Error", message: message)
                            }
                        }
                    default :
                        break
                    }
                }else{
                    debugPrint(error)
                }
            }
        })
    }
}
extension FavouriteDockViewController : UITableViewDataSource,UITableViewDelegate {
    func setUpTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "FavouriteDockTableViewCell", bundle: nil), forCellReuseIdentifier: FavouriteDockTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 10 : viewModel?.favouriteLocation?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavouriteDockTableViewCell", for: indexPath) as? FavouriteDockTableViewCell
        if isLoading{
            cell?.setShimmering(isShimmering: true)
        }else{
            if let favouriteLocation = viewModel?.favouriteLocation?[indexPath.row]{
                cell?.setShimmering(isShimmering: false)
                cell?.configure(chargerLocation: favouriteLocation,indexPath: indexPath,delegate: self)
            }else {
                return UITableViewCell()
            }
        }
        return cell ?? FavouriteDockTableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoVc = LocationInfoViewController()
            if let locationData = viewModel?.favouriteLocation?[indexPath.row]{
                if let latitude = UserDefaultManager.shared.getUserCurrentLocation()?.first, let longitude = UserDefaultManager.shared.getUserCurrentLocation()?.last{
                    infoVc.viewModel = LocationInfoViewModel(locationData: locationData,latitude: latitude, longitude: longitude)
                }
        }
        self.present(infoVc, animated: true, completion: nil)

    }
}
extension FavouriteDockViewController : FavouriteDockTableViewCellDelegate{
    func didSelectedFavouriteButton(at indexPath: IndexPath) {
        let indextoRemove = indexPath.row
        let locationId = viewModel?.favouriteLocation?[indextoRemove].id ?? ""
        viewModel?.removeFavouriteLocation(locationId: locationId, completion: { result in
            switch result{
            case .success(let response):
                if !response.status{
                    DispatchQueue.main.async {
                        self.showAlert(title: "Failed to Remove", message: response.message)
                    }
                }else{
                    self.viewModel?.favouriteLocation?.remove(at: indextoRemove)
                    DispatchQueue.main.async {
                        self.tableView.performBatchUpdates({
                            self.tableView.deleteRows(at: [IndexPath(row: indextoRemove, section: 0)], with: .left)
                        }, completion: { _ in
                            self.tableView.reloadData()
                            if self.viewModel?.favouriteLocation?.count ?? 0 == 0{
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        })
                        ToastManager.shared.showToast(message: response.message ?? "Location removed from favourite")
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        })
    }
}
