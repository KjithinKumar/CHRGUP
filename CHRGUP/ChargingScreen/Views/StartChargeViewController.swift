//
//  StartChargeViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/04/25.
//

import UIKit

class StartChargeViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var chargingTitleLabel: UILabel!
    @IBOutlet weak var titleOneLabel: UILabel!
    @IBOutlet weak var subtitleOneLabel: UILabel!
    @IBOutlet weak var titletwoLabel: UILabel!
    @IBOutlet weak var subtitleTwoLabel: UILabel!
    @IBOutlet weak var titleThreeLabel: UILabel!
    @IBOutlet weak var subtitleThreeLabel: UILabel!
    @IBOutlet weak var titleFourLabel: UILabel!
    @IBOutlet weak var subtitleFourLabel: UILabel!
    @IBOutlet weak var titleFiveLabel: UILabel!
    @IBOutlet weak var subtitleFiveLabel: UILabel!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var secondViewTitleLabel: UILabel!
    var viewModel : StartChargeViewModelInterface?
    @IBOutlet weak var infoButton: UIButton!
    var payLoad : QRPayload?
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
        checkIfPopShouldShow()
        
    }
    func checkIfPopShouldShow(){
        if UserDefaultManager.shared.showPopUp(){
            // Show popup automatically on screen load
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.showPopUp(sender: self.infoButton)
                // Dismiss the popup after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UIView.animate(withDuration: 0.1) {
                        self.dismissPopup()
                    }
                }
            }
        }
    }
    func setUpUi(){
        view.backgroundColor = ColorManager.backgroundColor
        
        chargingTitleLabel.text = AppStrings.StartCharging.title
        chargingTitleLabel.font = FontManager.bold(size: 25)
        chargingTitleLabel.textColor = ColorManager.textColor
        
        titleOneLabel.text = AppStrings.StartCharging.titleOne
        titleOneLabel.font = FontManager.regular()
        titleOneLabel.textColor = ColorManager.subtitleTextColor
        
        titletwoLabel.text = AppStrings.StartCharging.titleTwo
        titletwoLabel.font = FontManager.regular()
        titletwoLabel.textColor = ColorManager.subtitleTextColor
        
        titleThreeLabel.text = AppStrings.StartCharging.titleThree
        titleThreeLabel.textColor = ColorManager.subtitleTextColor
        titleOneLabel.font = FontManager.regular()
        
        titleFourLabel.text = AppStrings.StartCharging.titleFour
        titleFourLabel.textColor = ColorManager.subtitleTextColor
        titleFourLabel.font = FontManager.regular()
        
        titleFiveLabel.text = AppStrings.StartCharging.titleFive
        titleFiveLabel.textColor = ColorManager.subtitleTextColor
        titleFiveLabel.font = FontManager.regular()
        
        secondView.layer.cornerRadius = 10
        secondView.backgroundColor = ColorManager.secondaryBackgroundColor
        
        secondViewTitleLabel.text = AppStrings.StartCharging.downViewTitle
        secondViewTitleLabel.textColor = ColorManager.subtitleTextColor
        secondViewTitleLabel.font = FontManager.light()
        
        closeButton.tintColor = ColorManager.textColor
        
        infoButton.tintColor = ColorManager.textColor
        
        setUpData()
        configureNavBar()
    }
    func setUpData(){
        subtitleOneLabel.text = viewModel?.chargerDetails()?.chargerInfo?.name
        subtitleTwoLabel.text = viewModel?.chargerDetails()?.location?.locationName
        subtitleFourLabel.text = viewModel?.chargerDetails()?.location?.freePaid?.charging ?? false ? "FREE" : "PAID"
        subtitleFiveLabel.text = viewModel?.chargerDetails()?.location?.freePaid?.parking ?? false ? "FREE" : "PAID"
        let bulletPoint = "• "
        let text = "\(viewModel?.chargerDetails()?.chargerInfo?.type ?? "") - \(viewModel?.chargerDetails()?.chargerInfo?.powerOutput ?? "")"
        if viewModel?.chargerDetails()?.chargerInfo?.type == "DC"{
            let attributedString = NSMutableAttributedString(string: bulletPoint, attributes: [.foregroundColor: ColorManager.dcbulletColor,.font : FontManager.bold()])
            attributedString.append(NSAttributedString(string: text, attributes: [.foregroundColor: ColorManager.textColor]))
            subtitleThreeLabel.attributedText = attributedString
        }else{
            let attributedString = NSMutableAttributedString(string: bulletPoint, attributes: [.foregroundColor: ColorManager.acbulletColor])
            attributedString.append(NSAttributedString(string: text, attributes: [.foregroundColor: ColorManager.textColor]))
            subtitleThreeLabel.attributedText = attributedString
        }
    }
    func configureNavBar(){
        let leftBarButton = UIBarButtonItem(customView: closeButton)
        let rightBarButton = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        showPopUp(sender: sender)
    }
    @objc func dismissPopup() {
        if let overlay = view.viewWithTag(9999) {
            overlay.removeFromSuperview()
        }
    }
    func showPopUp(sender : Any? = nil){
        if let existing = view.viewWithTag(9999) {
            existing.removeFromSuperview()
        }
        
        let dismissView = UIControl()
        dismissView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dismissView.translatesAutoresizingMaskIntoConstraints = false
        dismissView.tag = 9999
        dismissView.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        view.addSubview(dismissView)
        
        NSLayoutConstraint.activate([
            dismissView.topAnchor.constraint(equalTo: view.topAnchor),
            dismissView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dismissView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dismissView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        let leftItems = [
            LegendItem(iconName: "VectorGreen", title: "Available", shouldAnimate: false),
            LegendItem(iconName: "VectorGreen", title: "Ready to charge", shouldAnimate: true),
            LegendItem(iconName: "VectorBlue", title: "Charging", shouldAnimate: true)
        ]
        
        let rightItems = [
            LegendItem(iconName: "VectorBlue", title: "Charging done", shouldAnimate: false),
            LegendItem(iconName: "VectorRed", title: "Fault", shouldAnimate: false),
            LegendItem(iconName: "VectorWhite", title: "Connecting to Internet", shouldAnimate: true)
        ]
        
        let popup = LegendsPopupView(leftItems: leftItems, rightItems: rightItems)
        popup.tag = 999
        dismissView.addSubview(popup)
        
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: (sender as AnyObject).bottomAnchor, constant: 8),
            popup.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            popup.widthAnchor.constraint(equalToConstant: 365)
        ])
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func startChargingPressed(_ sender: Any) {
        startButton.isUserInteractionEnabled = false
        startButton.imageView?.tintColor = ColorManager.secondaryBackgroundColor
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = ColorManager.backgroundColor
        startButton.imageView?.addSubview(indicator)
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: startButton.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: startButton.centerYAnchor)
        ])
        let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber ?? ""
        guard let payLoad = payLoad else { return }
        viewModel?.startCharging(phoneNumber: mobileNumber, qrpayload: payLoad) {[weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async{
                switch result {
                case .success(let response):
                    if response.status{
                        ToastManager.shared.showToast(message: response.message ?? "Charging started")
                        let statusVc = ChargingStatusViewController()
                        statusVc.viewModel = ChargingStatusViewModel(networkManager: NetworkManager())
                        self.navigationController?.setViewControllers([statusVc], animated: true)
                    }else{
                        self.showAlert(title: "Error", message: response.message ?? "Something went wrong")
                        self.startButton.isUserInteractionEnabled = true
                        indicator.stopAnimating()
                        indicator.removeFromSuperview()
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
}
