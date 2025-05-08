//
//  LocationInfoViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/03/25.
//

import UIKit

protocol locationInfoViewControllerDelegate : AnyObject {
    func didTapFavouriteButton(at indexPath: IndexPath)
}

class LocationInfoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addToFavouriteButton: UIButton!
    @IBOutlet weak var favouriteStackView: UIStackView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanQrButton: UIButton!
    @IBOutlet weak var Middleview: UIView!
    let pageController = UIPageControl()
    
    var viewModel : LocationInfoViewModelInterface?
    weak var delegate : locationInfoViewControllerDelegate?
    var indexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        configureUi()
        setUpTableView()
        
    }
    func reloadUi(){
        tableView.reloadData()
        collectionView.reloadData()
    }

    func configureUi(){
        guard let viewModel = viewModel else { return }
        view.backgroundColor = ColorManager.secondaryBackgroundColor
        Middleview.widthAnchor.constraint(equalToConstant: 2).isActive = true
        
        titleLabel.text = viewModel.locationName
        titleLabel.font = FontManager.bold(size: 27)
        titleLabel.textColor = ColorManager.textColor
        
        distanceLabel.text = viewModel.distance
        distanceLabel.textColor = ColorManager.textColor
        distanceLabel.font = FontManager.bold(size: 17)
        
        dismissButton.tintColor = ColorManager.buttonColorwhite
        
        if viewModel.isAvailable{
            statusLabel.text = "OPEN"
            statusLabel.textColor = ColorManager.primaryColor
            statusLabel.font = FontManager.regular()
        }else{
            statusLabel.text = "CLOSED"
            statusLabel.textColor = .red
            statusLabel.font = FontManager.regular()
        }
        
        setFavouritebutton(favourite: viewModel.isFavourite)
        
        scanQrButton.layer.cornerRadius = 25
        scanQrButton.setTitle(AppStrings.Map.scanButtonTitle, for: .normal)
        scanQrButton.titleLabel?.font = FontManager.bold(size: 17)
        scanQrButton.imageView?.tintColor = ColorManager.backgroundColor
        scanQrButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        scanQrButton.backgroundColor = ColorManager.primaryColor
        
        tableView.backgroundColor = ColorManager.secondaryBackgroundColor
        
    }
    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func addToFavouriteButtonPressed(_ sender: Any) {
        viewModel?.addToFavourtie(networkManager: NetworkManager(), completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result{
                case .success(let response):
                    if !response.status{
                        self.showAlert(title: "Failed to add", message: response.message)
                    }else{
                        ToastManager.shared.showToast(message: response.message ?? "Location added to favourite")
                        self.setFavouritebutton(favourite: true)
                        if let indexPath = self.indexPath{
                            self.delegate?.didTapFavouriteButton(at: indexPath)
                        }
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        })
    }
    func setFavouritebutton(favourite : Bool){
        if favourite{
            addToFavouriteButton.setTitle(" Favourite", for: .normal)
            addToFavouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            addToFavouriteButton.tintColor = ColorManager.primaryColor
            addToFavouriteButton.setTitleColor(ColorManager.primaryColor, for: .normal)
            addToFavouriteButton.isUserInteractionEnabled = false
        }else{
            addToFavouriteButton.setTitleColor(ColorManager.subtitleTextColor, for: .normal)
            addToFavouriteButton.setTitle(" Add To Favourite", for: .normal)
            addToFavouriteButton.setImage(UIImage(systemName: "plus"), for: .normal)
            addToFavouriteButton.tintColor = ColorManager.subtitleTextColor
            addToFavouriteButton.isUserInteractionEnabled = true
        }
    }
    @IBAction func scanQrButtonPressed(_ sender: Any) {
        let scanVc = ScanQrViewController()
        scanVc.viewModel = ScanQrViewModel(networkManager: NetworkManager())
        scanVc.modalPresentationStyle = .fullScreen
        let navController = UINavigationController(rootViewController: scanVc)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.tintColor = ColorManager.textColor
        self.present(navController, animated: true)
    }
    @IBAction func MapsButtonPressed(_ sender: Any) {
        if let latitude = viewModel?.locationLatitude, let longitude = viewModel?.locationLongitude{
            let appleMapsURL = "http://maps.apple.com/?q=\(latitude),\(longitude)&dirflg=d"
            let googleMapsURL = "comgooglemaps://?q=\(latitude),\(longitude)&directionsmode=driving"
            
            if let googleMaps = URL(string: googleMapsURL), UIApplication.shared.canOpenURL(googleMaps) {
                UIApplication.shared.open(googleMaps, options: [:], completionHandler: nil) // Open Google Maps
            } else if let appleMaps = URL(string: appleMapsURL) {
                UIApplication.shared.open(appleMaps, options: [:], completionHandler: nil) // Open Apple Maps
            }
        }
    }
    func setUpPageControl(){
        view.addSubview(pageController)
        pageController.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([pageController.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
                                     pageController.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)])
        pageController.numberOfPages = viewModel?.locationImage.count ?? 0
        pageController.currentPage = 0
        pageController.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)

    }
}
extension LocationInfoViewController: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate{
    func setUpCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: "LocationImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: LocationImageCollectionViewCell.identifier)
        setUpPageControl()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.locationImage.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationImageCollectionViewCell.identifier, for: indexPath) as? LocationImageCollectionViewCell
        if let imageString = viewModel?.locationImage[indexPath.row]{
            cell?.configure(with: imageString)
        }
        cell?.contentView.frame = collectionView.bounds
        return cell ?? LocationImageCollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageController.currentPage = Int(pageIndex)
    }
    @objc func pageControlTapped(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension LocationInfoViewController : UITableViewDelegate,UITableViewDataSource{
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "ChargersTableViewCell", bundle: nil), forCellReuseIdentifier: ChargersTableViewCell.identifier)
        tableView.register(UINib(nibName: "TariffTableViewCell", bundle: nil), forCellReuseIdentifier: TariffTableViewCell.identifier)
        tableView.register(UINib(nibName: "facilitiesTableViewCell", bundle: nil), forCellReuseIdentifier: facilitiesTableViewCell.identifier)
        tableView.register(UINib(nibName: "LabelSublabelTableViewCell", bundle: nil), forCellReuseIdentifier: LabelSublabelTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.locationCellType.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel?.locationCellType[indexPath.row]{
        case .chargers:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChargersTableViewCell.identifier) as? ChargersTableViewCell{
                if let locationData = viewModel?.locationData{
                    if let pointsAvailable = viewModel?.pointsAvailable{
                        let statusPriority: [String: Int] = ["Available": 0, "Inactive": 2]
                        let sortedChargers = locationData.chargerInfo.sorted {
                            (statusPriority[$0.status ?? ""] ?? 1) < (statusPriority[$1.status ?? ""] ?? 1)
                        }
                        cell.configure(chargerInfo: sortedChargers, pointsAvailable: pointsAvailable, delegate: self)
                        cell.backgroundColor = .clear
                    }
                }
                return cell
            }
        case .tarrif:
            if let cell = tableView.dequeueReusableCell(withIdentifier: TariffTableViewCell.identifier) as? TariffTableViewCell{
                if let locationData = viewModel?.locationData{
                    cell.configure(charging: locationData.freePaid.charging, parking: locationData.freePaid.parking)
                    cell.backgroundColor = .clear
                }
                return cell
            }
        case .facilities:
            if let cell = tableView.dequeueReusableCell(withIdentifier: facilitiesTableViewCell.identifier) as? facilitiesTableViewCell{
                if let locationData = viewModel?.locationData{
                    if let facilities = locationData.facilities {
                        cell.facilities = facilities
                        cell.configure(facilities: facilities)
                    }
                    cell.backgroundColor = .clear
                }
                return cell
            }
        case .titleSubTitle(let subType):
            if let cell = tableView.dequeueReusableCell(withIdentifier: LabelSublabelTableViewCell.identifier) as? LabelSublabelTableViewCell{
                if let locationData = viewModel?.locationData{
                    switch subType{
                    case .workingHours:
                        let openingHours = "\(locationData.workingDays) | \(locationData.workingHours)"
                        cell.configure(title: AppStrings.ChargerInfo.workingHoursText, subtitle: openingHours)
                    case .address:
                        let address = locationData.address
                        cell.configure(title: AppStrings.ChargerInfo.AddressText, subtitle: address)
                    case .contact:
                        let contact = locationData.salesManager?.phoneNumber ?? locationData.dealer?.phoneNumber ?? ""
                        cell.configure(title: AppStrings.ChargerInfo.contactText, subtitle: contact)
                    }
                }
                cell.backgroundColor = .clear
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
}
extension LocationInfoViewController: ChargersTableViewCellDelegate{
    func didSelectRaiseTicket() {
        if let presentingVC = presentingViewController as? UINavigationController,
           let _ = presentingVC.viewControllers.first {
            self.dismiss(animated: true) {
                presentingVC.popToRootViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let helpAndSupportVc = HelpandSupportViewController()
                    helpAndSupportVc.viewModel = HelpAndSupportViewModel(networkManager: NetworkManager(), delegate: nil)
                    presentingVC.pushViewController(helpAndSupportVc, animated: true)
                }
            }
        }
    }
}
