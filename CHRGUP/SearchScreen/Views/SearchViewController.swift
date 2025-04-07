//
//  SearchViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 01/04/25.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel : SearchViewModelInterface?
    var isLoading : Bool = false
    private var debounceTimer: Timer?
    private var searchLabelHeightConstraint: NSLayoutConstraint?
    private var tableViewTopConstraint: NSLayoutConstraint?
    private var searchText : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
        setupSearchBar()
        setUpTableView()
        setupConstraints()
        showRecentChargers()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
    }
    func setUpUi(){
        view.backgroundColor = ColorManager.backgroundColor
        navigationItem.title = "Search Chargers"
        searchLabel.textColor = ColorManager.subtitleTextColor
    }
    func fetchData(query : String){
        isLoading = true
        tableView.reloadData()
        self.searchText = query
        viewModel?.fetchChargers(string: query) { result in
            DispatchQueue.main.async {
                switch result{
                case .success(let response):
                    if response.success{
                        self.isLoading = false
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                    }else{
                        self.isLoading = false
                        self.tableView.isHidden = true
                        ToastManager.shared.showToast(message: response.message ?? "Something went wrong")
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
    @objc func hideKeyboard(){
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    // MARK: - Debounce API Call
       private func debounceSearch(text: String?) {
           debounceTimer?.invalidate() // Cancel previous timer if exists
           
           guard let searchText = text, !searchText.isEmpty else {
               searchLabelAnimated(ishidden: false)
               return
           }
           searchLabelAnimated(ishidden: true)
           debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
               self?.fetchData(query: searchText)
           }
       }
    private func setupConstraints() {
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        searchLabelHeightConstraint = searchLabel.heightAnchor.constraint(equalToConstant: 25)
        searchLabelHeightConstraint?.isActive = true
    }
}

extension SearchViewController: UISearchBarDelegate {
    func setupSearchBar(){
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        searchBar.placeholder = "Search chargers"
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchLabelAnimated(ishidden: true)
        if searchBar.text != nil, let text = searchBar.text{
            fetchData(query: text)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debounceSearch(text: searchText)
        if searchText.isEmpty{
            showRecentChargers()
        }
    }
    
    func searchLabelAnimated(ishidden: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.searchLabelHeightConstraint?.constant = ishidden ? 0 : 25
            self.searchLabel.alpha = ishidden ? 0 : 1 // Optional: smooth fade effect
            self.view.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        debounceTimer?.invalidate()
        searchLabelAnimated(ishidden: false)
        showRecentChargers()
    }
}
extension SearchViewController : UITableViewDataSource,UITableViewDelegate {
    func setUpTableView() {
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = ColorManager.backgroundColor
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 350, right: 0)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 5
        }
        return searchBar.text?.isEmpty ?? true ? viewModel?.recentChargers.count ?? 0 : viewModel?.chargers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier) as? SearchTableViewCell ?? SearchTableViewCell()
        if searchBar.text?.isEmpty ?? true {
            if let location = viewModel?.recentChargers[indexPath.row] {
                cell.configure(chargerLocation: location, searchText: "",recents: true)
                cell.setShimmering(isShimmering: false)
            }
        }else{
            if isLoading {
                cell.setShimmering(isShimmering: true)
            }else{
                if let location = viewModel?.chargers?[indexPath.row]{
                    cell.setShimmering(isShimmering: false)
                    cell.configure(chargerLocation: location,searchText: searchText ?? "",recents: false)
                }
            }
        }
        cell.backgroundColor = .clear
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoVc = LocationInfoViewController()
        if let userLatitude = UserDefaultManager.shared.getUserCurrentLocation()?.first, let userLongitude = UserDefaultManager.shared.getUserCurrentLocation()?.last{
            if searchBar.text?.isEmpty ?? true {
                if let locationData = viewModel?.recentChargers[indexPath.row]{
                    viewModel?.refreshLocationData(id: locationData.id) { result in
                        switch result {
                        case .success(let chargerData):
                            DispatchQueue.main.async {
                                infoVc.viewModel = LocationInfoViewModel(locationData: chargerData,latitude: userLatitude, longitude: userLongitude)
                                infoVc.reloadUi()
                                self.viewModel?.addRecentCharger(chargerData)
                            }
                            
                        case .failure(let error):
                            self.showAlert(title: "Error", message: error.localizedDescription)
                        }
                    }
                    infoVc.viewModel = LocationInfoViewModel(locationData: locationData,latitude: userLatitude, longitude: userLongitude)
                }
                
            }else{
                if let locationData = viewModel?.chargers?[indexPath.row]{
                    infoVc.viewModel = LocationInfoViewModel(locationData: locationData,latitude: userLatitude, longitude: userLongitude)
                    viewModel?.addRecentCharger(locationData)
                }
            }
        }
        self.present(infoVc, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.tableView.reloadData()
        }
        
    }
    private func showRecentChargers() {
        tableView.isHidden = viewModel?.recentChargers.isEmpty ?? true
        tableView.reloadData()
        isLoading = false
    }
}
