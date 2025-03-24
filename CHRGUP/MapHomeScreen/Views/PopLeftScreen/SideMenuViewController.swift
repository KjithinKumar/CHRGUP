//
//  SideMenuViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/03/25.
//

import UIKit
import SDWebImage

protocol SideMenuDelegate: AnyObject {
    func didSelectMenuOption(_ viewController: UIViewController)
}

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var firstStackView: UIStackView!
    @IBOutlet weak var popOverView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var vehicleButton: UIButton!
    
    weak var delegate : SideMenuDelegate?
    var viewModel : SideMenuViewModelInterface?
    private var menuWidthConstraint: NSLayoutConstraint?
    private let menuMaxWidth = UIScreen.main.bounds.width * 0.65
    var isLoading : Bool = true
    let indicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpPopoverView()
        setUpTableView()
        setUpVehicleButton()
        viewModel?.fetchVehicleDetails()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.frame.origin.x = -self.view.frame.width // Start off-screen
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.x = 0 // Slide in
        }
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismissToLeft()
    }
    func setUpUI(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        backgroundView.addGestureRecognizer(gesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        swipeGesture.direction = .left
        view.addGestureRecognizer(swipeGesture)
        
        titleLabel.attributedText = setHighlightedText(fullText: AppStrings.leftMenu.Title, highlightedWord: AppStrings.leftMenu.highlihtedTitle, highlightColor: ColorManager.primaryColor)
        
        closeButton.imageView?.tintColor = ColorManager.textColor
        
        profileImageView.tintColor = ColorManager.textColor
        
        self.firstStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.vehicleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        let userProfile = UserDefaultManager.shared.getUserProfile()
        profileImageView.layer.cornerRadius = 25
        if let image = userProfile?.profilePic{
            let url = URL(string: image)
            profileImageView.sd_setImage(with: url)
            profileImageView.clipsToBounds = true
        }
    }
    
    func setUpPopoverView(){
        popOverView.translatesAutoresizingMaskIntoConstraints = false
        popOverView.backgroundColor = ColorManager.secondaryBackgroundColor
    }
    func setUpVehicleButton(){
        popOverView.addSubview(vehicleButton)
        vehicleButton.translatesAutoresizingMaskIntoConstraints = false
        vehicleButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vehicleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        vehicleButton.titleLabel?.minimumScaleFactor = 0.5 // Adjust as needed
        vehicleButton.titleLabel?.lineBreakMode = .byTruncatingTail
        
        if isLoading{
            vehicleButton.addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.autoresizingMask = .flexibleWidth
            indicator.autoresizingMask = .flexibleHeight
            indicator.startAnimating()
            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: vehicleButton.centerYAnchor),
                indicator.trailingAnchor.constraint(equalTo: popOverView.trailingAnchor, constant: -35)])
        }else{
            indicator.hidesWhenStopped = true
            indicator.stopAnimating()
            let imageView = UIImageView(image: UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate))
            vehicleButton.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.autoresizingMask = .flexibleWidth
            imageView.autoresizingMask = .flexibleHeight
            imageView.tintColor = ColorManager.textColor
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: vehicleButton.centerYAnchor),
                imageView.trailingAnchor.constraint(equalTo: popOverView.trailingAnchor, constant: -35)])
        }
        vehicleButton.layer.borderWidth = 1
        vehicleButton.layer.cornerRadius = 5
        vehicleButton.layer.borderColor = ColorManager.primaryColor.cgColor
        vehicleButton.backgroundColor = ColorManager.secondaryBackgroundColor
    }
}
extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = ColorManager.secondaryBackgroundColor
        tableView.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: SideMenuTableViewCell.identifier)
        tableView.separatorColor = .clear
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.sideMenuItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.identifier) as? SideMenuTableViewCell ?? SideMenuTableViewCell()
        cell.configureCell(
            title: viewModel?.sideMenuItems[indexPath.row].title ?? "" ,
            leftImage: viewModel?.sideMenuItems[indexPath.row].icon ?? "")
        cell.backgroundColor = ColorManager.secondaryBackgroundColor
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedfield = viewModel?.sideMenuItems[indexPath.row]
        switch selectedfield?.sideMenuDestiantion{
        case .mygarage:
            let myGarageVc = GarageViewController()
            myGarageVc.viewModel = GarageViewModel(networkManager: NetworkManager(), delegate: myGarageVc)
            dismissView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                self.delegate?.didSelectMenuOption(myGarageVc)
            }
        case .helpandsupport:
            let helpAndSupportVc = HelpandSupportViewController()
            dismissView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                self.delegate?.didSelectMenuOption(helpAndSupportVc)
            }
        default:
            break
        }
    }
}

extension SideMenuViewController {
    func dismissToLeft() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.origin.x = -self.view.frame.width // Slide out
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    @objc func dismissView() {
        dismissToLeft()
    }
    func setHighlightedText(fullText: String, highlightedWord: String, highlightColor: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText,attributes: [.font: FontManager.bold(size: 28)] )
        let range = (fullText as NSString).range(of: highlightedWord)
        
        if range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: highlightColor, range: range)
        }
        return attributedString
    }
}

extension SideMenuViewController : sideMenuDelegate {
    func receivedVehicleDetails() {
        var menuItems : [UIAction] = []
        let userSelectedVehicle = UserDefaultManager.shared.getSelectedVehicle()
        let userVehicles = viewModel?.vehicleData
        for vehicle in userVehicles ?? [] {
            let make = vehicle.make
            let model = vehicle.model
            let variant = vehicle.variant
            let Vehiclename = "\(make) \(model) \(variant)"
            if userSelectedVehicle?.id == vehicle.id {
                DispatchQueue.main.async {
                    self.vehicleButton.setTitle("\u{2003}\(Vehiclename)\u{2003}\u{2003}", for: .normal)
                }
            }
            let action = UIAction(title : Vehiclename) { _ in
                self.vehicleButton.setTitle("\u{2003}\(Vehiclename)\u{2003}\u{2003}", for: .normal)
                UserDefaultManager.shared.saveSelectedVehicle(vehicle)
            }
            menuItems.append(action)
        }
        let addVehicleAttributedString = NSAttributedString(string: "+ Add Vehicle", attributes: [.foregroundColor: ColorManager.primaryColor])
        let addVehicleAction = UIAction(title: "+ Add Vehicle", handler: { _ in
            let vehicleVc = UserVehicleInfoViewController()
            vehicleVc.viewModel = UserVehicleInfoViewModel(delegate: vehicleVc, networkManager: NetworkManager())
            vehicleVc.userData = UserDefaultManager.shared.getUserProfile()
            vehicleVc.screenType = .addNew
            self.dismissView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                self.delegate?.didSelectMenuOption(vehicleVc)
            }
        })
        addVehicleAction.setValue(addVehicleAttributedString, forKey: "attributedTitle")
        menuItems.append(addVehicleAction)
        DispatchQueue.main.async {
            self.vehicleButton.menu = UIMenu(title: "", options: [], children: menuItems)
            self.vehicleButton.showsMenuAsPrimaryAction = true
            self.isLoading = false
            self.setUpVehicleButton()
        }
    }
    func didFailWithError(_ message: String, _ code: Int) {
        DispatchQueue.main.async {
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
        }
    }
}
