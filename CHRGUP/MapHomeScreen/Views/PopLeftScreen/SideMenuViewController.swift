//
//  SideMenuViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/03/25.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var firstStackView: UIStackView!
    @IBOutlet weak var popOverView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var vehicleButton: UIButton!
    
    var viewModel : SideMenuViewModelProtocolInterface?
    private var menuWidthConstraint: NSLayoutConstraint?
    private let menuMaxWidth = UIScreen.main.bounds.width * 0.65
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        configureBackground()
        setUpPopoverView()
        setUpTableView()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
            self.animatePopOVer()
        }
        setUpVehicleButton()
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
        
    }
    func configureBackground(){
        view.addSubview(backgroundView)
        backgroundView.backgroundColor = .clear
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     backgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                                     backgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                     backgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)])
    }
    
    func setUpPopoverView(){
        popOverView.translatesAutoresizingMaskIntoConstraints = false
        popOverView.backgroundColor = ColorManager.backgroundColor
        view.addSubview(popOverView)
        NSLayoutConstraint.activate([
            popOverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popOverView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            popOverView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        menuWidthConstraint = popOverView.widthAnchor.constraint(equalToConstant: 0)
        menuWidthConstraint?.isActive = true
    }
    func animatePopOVer(){
        UIView.animate(withDuration: 0.3) {
            self.menuWidthConstraint?.constant = self.menuMaxWidth
            self.view.layoutIfNeeded()
            self.backgroundView.backgroundColor = ColorManager.backgroundColor.withAlphaComponent(0.5) // Dim background
            self.firstStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            self.profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            self.profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            self.vehicleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
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
        
        
        var first = UIAction(title: "Vehicle one", state: .off) { _ in
            self.vehicleButton.setTitle("\u{2003}Vehicle one", for: .normal)
        }
        var third = UIAction(title: "Vehicle two", state: .off) { _ in
            self.vehicleButton.setTitle("\u{2003}Vehicle two", for: .normal)
        }
        var fourth = UIAction(title: "Vehicle three", state: .off) { _ in
            self.vehicleButton.setTitle("\u{2003}Vehicle three", for: .normal)
        }
        var second = UIAction(title: "+ Add vehicle", state: .off){ _ in
            print("one vehicle")
        }
        second.setValue(addVehicleAttributedString, forKey: "attributedTitle")
        
        
        
        var elements = [first,third,fourth,second]
        vehicleButton.menu = UIMenu(title: "", options: [], children: elements)
        
    }
}
extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = ColorManager.backgroundColor
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
        cell.backgroundColor = ColorManager.backgroundColor
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}





extension SideMenuViewController {
    func dismissToLeft() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.menuWidthConstraint?.constant = 0
            self.view.layoutIfNeeded()
            self.backgroundView.layoutIfNeeded()
            self.backgroundView.backgroundColor = .clear
            self.profileImageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.profileImageView.widthAnchor.constraint(equalToConstant: 0).isActive = true
            
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
