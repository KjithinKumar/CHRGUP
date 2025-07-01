//
//  ChargingStatusViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/04/25.
//

import UIKit
import Lottie
import UserNotifications


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
    @IBOutlet weak var timeStackView: UIStackView!
    
    private let progressLayer = CAShapeLayer()
    private let backView = UIView()
    private let batteryPercentageLabel: UILabel = UILabel()
    
    var viewModel : ChargingStatusViewModelInterface?
    var payLoad : QRPayload?
    var pingTimer : Timer?
    var labelUpdateTimer: Timer?
    var lastPingDate: Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpAnimations()
        startPingTimer()
        setupProgressLayer()
    }
    deinit{
        pingTimer?.invalidate()
        labelUpdateTimer?.invalidate()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pingTimer?.invalidate()
        labelUpdateTimer?.invalidate()
    }
    @IBAction func stopButtonPressed(_ sender: Any) {
        pingTimer?.invalidate()
        labelUpdateTimer?.invalidate()
        disableButtonWithActivityIndicator(stopButton)
        navigationController?.navigationBar.isHidden = true
        viewModel?.stopCharging { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result{
                case .success(let response):
                    if response.status{
                        ToastManager.shared.showToast(message: response.message ?? "Charging Stopped")
                        iOSWatchSessionManger.shared.sendStatusToWatch()
                    }else{
                        self.showAlert(title: "Error", message: response.message)
                        self.navigationController?.navigationBar.isHidden = false
                        self.stopButton.setTitleColor(ColorManager.backgroundColor, for: .normal)
                        self.enableButtonAndRemoveIndicator(self.stopButton)
                    }
                    self.sendChargingEndedNotification(message: response.message ?? "Your charging session has ended.")
                    self.stopChargingForce()
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
        stopButton.setTitleColor(ColorManager.buttonTextColor, for: .normal)
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
        titleLabel.textColor = ColorManager.primaryTextColor
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTimeString = dateFormatter.string(from: Date())
        chargingTimeLabel.attributedText = self.getFormattedTimeDifference(from: currentTimeString)
        
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
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColorManager.primaryTextColor.withAlphaComponent(0.2)
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
    func setupProgressLayer() {
        lottieView.layoutIfNeeded()
        backView.layer.cornerRadius = backView.frame.width / 2
        let radius = backView.frame.width / 2 - 5
        let centerPoint = CGPoint(x: backView.bounds.midX, y: backView.bounds.midY)
        let circlePath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = ColorManager.primaryTextColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        lottieView.layer.addSublayer(progressLayer)
    }
    func updateBatteryProgress(_ batteryPercentage: Int) {
        guard batteryPercentage > 0 else {
            progressLayer.isHidden = true
            batteryPercentageLabel.removeFromSuperview()
            return
        }
        let clamped = max(0, min(100, batteryPercentage))
        let progress = CGFloat(clamped) / 100.0
        timeStackView.insertArrangedSubview(batteryPercentageLabel, at: 0)
        batteryPercentageLabel.text = "\(clamped)% Charged"
        batteryPercentageLabel.font = FontManager.bold(size: 20)
        batteryPercentageLabel.textColor = ColorManager.primaryTextColor
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        progressLayer.strokeEnd = progress
        CATransaction.commit()
    }
    func startPingTimer() {
        pingTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fetchData), userInfo: nil, repeats: true)
        RunLoop.main.add(pingTimer!, forMode: .common)
        labelUpdateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLastPingLabel), userInfo: nil, repeats: true)
        RunLoop.main.add(labelUpdateTimer!, forMode: .common)
    }
    @objc func fetchData(){
        viewModel?.fetchChargingStatus { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status{
                        if let chargingStatus = response.data, let startTime = chargingStatus.startTimeIST, let cost = chargingStatus.costPerUnit {
                            self.updateBatteryProgress(chargingStatus.batterypercentage ?? 0)
                            let chargingTime = self.getFormattedTimeDifference(from: startTime)
                            self.chargingTimeLabel.attributedText =  chargingTime
                            self.priceLabel.text = "₹ \(cost.amount ?? 0)/Unit"
                            let energyConsumed = self.convertWhToKWh(chargingStatus.meterValueDifference)
                            self.eneryconsumedLabel.text = " \(energyConsumed)"
                            UserDefaultManager.shared.saveSessionStatus(response.data?.status)
                            iOSWatchSessionManger.shared.sendStatusToWatch()
                            self.lastPingDate = Date()
                            Task {
                                let token = await ChargingLiveActivityManager.updateActivity(time: chargingTime.string, energy: energyConsumed,chargingTitle: "charging is in progress")
                                if let token = token {
                                    self.viewModel?.pushLiveApnToken(apnToken: token,event: "update") { [weak self] result in
                                        guard let _ = self else { return }
                                        switch result {
                                        case .success(let response):
                                            debugPrint(response)
                                        case .failure(let error):
                                            debugPrint(error)
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        self.sendChargingEndedNotification(message: response.message ?? "Your charging session has ended.")
                        self.stopChargingForce()
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
    func stopChargingForce() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){ [weak self] in
            guard let self = self else { return }
            Task {
                if let token = await ChargingLiveActivityManager.endActivity(){
                    self.viewModel?.pushLiveApnToken(apnToken: token,event: "stop") { [weak self] result in
                        guard let _ = self else { return }
                        switch result {
                        case .success(let response):
                            debugPrint(response)
                        case .failure(let error):
                            debugPrint(error)
                        }
                    }
                }
            }
            self.pingTimer?.invalidate()
            self.labelUpdateTimer?.invalidate()
            let receiptVc = ReceiptViewController()
            receiptVc.viewModel = ReceiptViewModel(networkManager: NetworkManager())
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.setViewControllers([receiptVc], animated: true)
        }
    }
    func getFormattedTimeDifference(from dateString: String) -> NSAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current

        guard let pastDate = dateFormatter.date(from: dateString) else {
            return NSAttributedString(string: "Invalid date")
        }

        let currentDate = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: pastDate, to: currentDate)

        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        // Colors and fonts
        let numberColor = ColorManager.textColor
        let unitColor = ColorManager.thirdBackgroundColor
        let font = FontManager.bold(size: 35)
        
        // Build attributed string
        let attributed = NSMutableAttributedString()
        attributed.append(NSAttributedString(string: String(format: "%02d", hours),
                                             attributes: [.foregroundColor: numberColor, .font: font]))
        attributed.append(NSAttributedString(string: " h : ",
                                             attributes: [.foregroundColor: unitColor, .font: font]))
        attributed.append(NSAttributedString(string: String(format: "%02d", minutes),
                                             attributes: [.foregroundColor: numberColor, .font: font]))
        attributed.append(NSAttributedString(string: " m",
                                             attributes: [.foregroundColor: unitColor, .font: font]))
        return attributed
    }
}

extension ChargingStatusViewController : UNUserNotificationCenterDelegate  {
    func requestNotificationPermission() {
        sendChargingStartedNotification()
    }
    func sendChargingStartedNotification() {
        NotificationManager.shared.sendChargingStartedNotification()
    }
    func sendChargingEndedNotification(message : String) {
        NotificationManager.shared.sendChargingEndedNotification(message: message)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
}
