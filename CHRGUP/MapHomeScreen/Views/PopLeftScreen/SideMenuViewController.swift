//
//  SideMenuViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/03/25.
//

import UIKit
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
    var viewModel : SideMenuViewModelProtocolInterface?
    private var menuWidthConstraint: NSLayoutConstraint?
    private let menuMaxWidth = UIScreen.main.bounds.width * 0.65
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpPopoverView()
        setUpTableView()
        setUpVehicleButton()
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
        self.profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.vehicleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    func setUpPopoverView(){
        popOverView.translatesAutoresizingMaskIntoConstraints = false
        popOverView.backgroundColor = ColorManager.secondaryBackgroundColor

    }

    
    func setUpVehicleButton(){
        popOverView.addSubview(vehicleButton)
        vehicleButton.translatesAutoresizingMaskIntoConstraints = false
        vehicleButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate))
        vehicleButton.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.autoresizingMask = .flexibleWidth
        imageView.autoresizingMask = .flexibleHeight
        imageView.tintColor = ColorManager.textColor
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: vehicleButton.centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: popOverView.trailingAnchor, constant: -35)])
        vehicleButton.layoutSubviews()
        vehicleButton.setTitle("\u{2003}vehicle", for: .normal)
        vehicleButton.layer.borderWidth = 1
        vehicleButton.layer.cornerRadius = 5
        vehicleButton.layer.borderColor = ColorManager.primaryColor.cgColor
        vehicleButton.backgroundColor = ColorManager.secondaryBackgroundColor
        let addVehicleAttributedString = NSAttributedString(string: "+ Add Vehicle", attributes: [.foregroundColor: ColorManager.primaryColor])
        
        
        let first = UIAction(title: "Vehicle one", state: .off) { _ in
            self.vehicleButton.setTitle("\u{2003}Vehicle one", for: .normal)
        }
        let third = UIAction(title: "Vehicle two", state: .off) { _ in
            self.vehicleButton.setTitle("\u{2003}Vehicle two", for: .normal)
        }
        let fourth = UIAction(title: "Vehicle three", state: .off) { _ in
            self.vehicleButton.setTitle("\u{2003}Vehicle three", for: .normal)
        }
        let second = UIAction(title: "+ Add vehicle", state: .off){ _ in
            print("one vehicle")
        }
        second.setValue(addVehicleAttributedString, forKey: "attributedTitle")
    
        let elements = [first,third,fourth,second]
        vehicleButton.menu = UIMenu(title: "", options: [], children: elements)
        
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
