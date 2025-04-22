//
//  ChargingStatusViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/04/25.
//

import UIKit
import Lottie

class ChargingStatusViewController: UIViewController {
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var energyConsumedTitle: UILabel!
    @IBOutlet weak var eneryconsumedLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chargingTimeLabel: UILabel!
    @IBOutlet weak var lastPingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    
    var viewModel : ChargingStatusViewModelInterface?
    var payLoad : QRPayload?
    var pingTimer : Timer?
    var labelUpdateTimer: Timer?
    var lastPingDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpAnimations()
        requestNotificationPermission()
        startPingTimer()
        
    }
    deinit{
        pingTimer?.invalidate()
        labelUpdateTimer?.invalidate()
    }
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopButton.isUserInteractionEnabled = false
        stopButton.setTitleColor(ColorManager.primaryColor, for: .normal)
        let indicator = UIActivityIndicatorView()
        indicator.color = ColorManager.backgroundColor
        view.addSubview(indicator)
        indicator.startAnimating()
        indicator.style = .medium
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: stopButton.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: stopButton.centerYAnchor)
        ])
        
        navigationController?.navigationBar.isHidden = true
        viewModel?.stopCharging { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result{
                case .success(let response):
                    if response.status{
                        ToastManager.shared.showToast(message: response.message ?? "Charging Stopped")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            let receiptVc = ReceiptViewController()
                            receiptVc.viewModel = ReceiptViewModel(networkManager: NetworkManager())
                            self.navigationController?.navigationBar.isHidden = false
                            self.navigationController?.setViewControllers([receiptVc], animated: true)
                        }
                    }else{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            let receiptVc = ReceiptViewController()
                            receiptVc.viewModel = ReceiptViewModel(networkManager: NetworkManager())
                            self.navigationController?.navigationBar.isHidden = false
                            self.navigationController?.setViewControllers([receiptVc], animated: true)
                        }
                        self.showAlert(title: "Error", message: response.message)
                        self.navigationController?.navigationBar.isHidden = false
                        self.stopButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
                        indicator.removeFromSuperview()
                        self.stopButton.isUserInteractionEnabled = true
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func infoButtonPressed(_ sender: Any) {
        showPopUp(sender: sender)
    }
    func setUpUI(){
        view.backgroundColor = ColorManager.backgroundColor
        
        lottieView.backgroundColor = ColorManager.backgroundColor
        
        infoButton.tintColor = ColorManager.textColor
        
        dismissButton.tintColor = ColorManager.textColor
        
        stopButton.backgroundColor = ColorManager.primaryColor
        stopButton.setTitle(AppStrings.chargingStatus.stopChargingText, for: .normal)
        stopButton.titleLabel?.font = FontManager.bold(size: 18)
        stopButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
        stopButton.layer.cornerRadius = 20
        
        priceLabel.text = "₹ 0.000/Unit"
        priceLabel.textColor = ColorManager.subtitleTextColor
        priceLabel.font = FontManager.regular()
        
        timeLabel.text = AppStrings.chargingStatus.chargingTimeText
        timeLabel.textColor = ColorManager.subtitleTextColor
        timeLabel.font = FontManager.regular()
        
        energyConsumedTitle.text = AppStrings.chargingStatus.energyConsumedText
        energyConsumedTitle.font = FontManager.regular()
        energyConsumedTitle.textColor = ColorManager.subtitleTextColor
        
        titleLabel.text = AppStrings.chargingStatus.title
        titleLabel.font = FontManager.bold(size: 25)
        titleLabel.textColor = ColorManager.primaryColor
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTimeString = dateFormatter.string(from: Date())
        if let chargingTime = viewModel?.getFormattedTimeDifference(from: currentTimeString){
            chargingTimeLabel.attributedText = chargingTime
        }
        
        eneryconsumedLabel.text = " 0.0000 kWh"
        eneryconsumedLabel.textColor = ColorManager.textColor
        eneryconsumedLabel.font = FontManager.bold(size: 17)
        
        lastPingLabel.textColor = ColorManager.subtitleTextColor
        lastPingLabel.font = FontManager.light()
        
        configureNavBar()
    }
    func configureNavBar(){
        let leftBarButton = UIBarButtonItem(customView: dismissButton)
        let rightBarButton = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setUpAnimations(){
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColorManager.primaryColor.withAlphaComponent(0.15)
        backView.layer.cornerRadius = lottieView.frame.width / 2
        backView.clipsToBounds = true
        lottieView.addSubview(backView)
        let animationView = LottieAnimationView(name: "charging_anim")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleToFill
        animationView.loopMode = .loop
        animationView.play()
        
        lottieView.addSubview(animationView)
        NSLayoutConstraint.activate([ animationView.centerXAnchor.constraint(equalTo: lottieView.centerXAnchor),
                                      animationView.centerYAnchor.constraint(equalTo: lottieView.centerYAnchor),
                                      animationView.widthAnchor.constraint(equalToConstant: 425),
                                      animationView.heightAnchor.constraint(equalToConstant: 425)])
        NSLayoutConstraint.activate([
                backView.centerXAnchor.constraint(equalTo: lottieView.centerXAnchor),
                backView.centerYAnchor.constraint(equalTo: lottieView.centerYAnchor),
                backView.widthAnchor.constraint(equalTo: lottieView.widthAnchor),
                backView.heightAnchor.constraint(equalTo: lottieView.heightAnchor)
            ])
        
    }
    func startPingTimer() {
        pingTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fetchData), userInfo: nil, repeats: true)
        RunLoop.main.add(pingTimer!, forMode: .common)
        labelUpdateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLastPingLabel), userInfo: nil, repeats: true)
        RunLoop.main.add(labelUpdateTimer!, forMode: .common)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){ [weak self] in
            guard let self = self else { return }
            self.fetchData()
        }
    }
    
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            success, error in
            if success {
                print("Permission Granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Permission Denied: \(error)")
            }
        }
        
    }
    @objc func fetchData(){
        lastPingDate = Date()
        viewModel?.fetchChargingStatus { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status{
                        if let chargingStatus = response.data, let startTime = chargingStatus.startTimeIST, let cost = chargingStatus.costPerUnit {
                            let chargingTime = self.viewModel?.getFormattedTimeDifference(from: startTime)
                            self.chargingTimeLabel.attributedText =  chargingTime
                            self.priceLabel.text = "₹ \(cost.amount ?? 0)/Unit"
                            let energyConsumed = self.convertWhToKWh(chargingStatus.meterValueDifference)
                            self.eneryconsumedLabel.text = " \(energyConsumed)"
                            UserDefaultManager.shared.saveSessionStatus(response.data?.status)
                        }
                    }else{
                        self.showAlert(title: "Error", message: response.message)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
    @objc func updateLastPingLabel() {
        guard let lastPing = lastPingDate else {
            lastPingLabel.text = "Last Ping: Never"
            return
        }
        
        let secondsAgo = Int(Date().timeIntervalSince(lastPing))
        lastPingLabel.text = "Last Ping: \(secondsAgo)s ago"
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
    @objc func dismissPopup() {
        if let overlay = view.viewWithTag(9999) {
            overlay.removeFromSuperview()
        }
    }
    func convertWhToKWh(_ whString: String) -> String {
        let trimmed = whString.replacingOccurrences(of: "Wh", with: "").trimmingCharacters(in: .whitespaces)
        guard let wattHours = Double(trimmed) else {
            return "Invalid input"
        }

        let kilowattHours = wattHours / 1000
        return String(format: "%.4f kWh", kilowattHours)
    }
}
