//
//  ScanQrViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 07/04/25.
//

import UIKit
import AVFoundation
import Lottie

class ScanQrViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var orStackView: UIStackView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var codeManualButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    private var torch = false
    private var scannerAnimationView: LottieAnimationView?
    private var cameraManager: CameraManager?
    var viewModel : ScanQrViewModelInterface?
    private var activityIndicator: UIActivityIndicatorView?
    var isfromDeepLink : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScannerAnimation()
        
    }
    deinit{
        cameraManager?.stopSession()
    }
    override func viewDidLayoutSubviews() {
        guard !isfromDeepLink else { return }
        super.viewDidLayoutSubviews()
        cameraManager?.previewLayer?.frame = cameraView.bounds
        if cameraManager == nil {
            cameraManager = CameraManager(previewView: cameraView, onCodeScanned: { [weak self] scannedCode in
                guard let self = self else { return }
                self.showActivityIndicator(true)
                self.fetchChargerDetails(id: scannedCode.chargerId, scannedCode: scannedCode)
            })
            cameraManager?.startSession()
        }
    }
    func fetchChargerDetails(id: String,scannedCode : QRPayload){
        viewModel?.fetchChargerDetails(id: id,connectorId: scannedCode.connectorId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status{
                        if let data = response.data{
                            let startChargeVc = StartChargeViewController()
                            startChargeVc.viewModel = StartChargeViewModel(chargerInfo: data, networkManager: NetworkManager())
                            startChargeVc.payLoad = scannedCode
                            self.navigationController?.setViewControllers([startChargeVc], animated: true)
                        }
                    }else{
                        ToastManager.shared.showToast(message: response.message ?? "Invalid Qr")
                        self.showActivityIndicator(false)
                        self.showAlert(title: "Error", message: response.message)
                    }
                case .failure(let error):
                    AppErrorHandler.handle(error, in: self)
                }
            }
        }
    }
    func showActivityIndicator(_ show: Bool) {
        if show {
            if activityIndicator == nil {
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.color = ColorManager.primaryColor
                indicator.translatesAutoresizingMaskIntoConstraints = false
                indicator.backgroundColor = .black
                cameraView.addSubview(indicator)
                
                NSLayoutConstraint.activate([
                    indicator.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor)
                ])
                
                indicator.startAnimating()
                cameraManager?.stopSession()
                activityIndicator = indicator
            }
        } else {
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
            cameraManager?.startSession()
        }
    }
    func setupUI(){
        view.backgroundColor = ColorManager.backgroundColor
        
        cameraView.backgroundColor = ColorManager.secondaryBackgroundColor
        cameraView.layer.borderWidth = 5
        cameraView.layer.borderColor = ColorManager.thirdBackgroundColor.cgColor
        cameraView.layer.cornerRadius = 8
        cameraView.clipsToBounds = true
        
        torchButton.tintColor = ColorManager.textColor
        toogleTorch(torchOn: torch)
        
        orLabel.textColor = ColorManager.textColor
        
        codeManualButton.setTitle("Enter Code Manually", for: .normal)
        codeManualButton.setTitleColor(ColorManager.textColor, for: .normal)
        codeManualButton.titleLabel?.font = FontManager.bold(size: 18)
        codeManualButton.backgroundColor = ColorManager.thirdBackgroundColor
        codeManualButton.layer.cornerRadius = 20
        
        closeButton.tintColor = ColorManager.textColor
        configureNavBar()
    }
    func configureNavBar(){
        navigationItem.title = "Scan QR"
        let barButton = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = barButton
    }
    func toogleTorch(torchOn: Bool){
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular, scale: .large)
        let torchOnImage = UIImage(systemName: "flashlight.on.circle", withConfiguration: largeConfig)
        let torchOffImage = UIImage(systemName: "flashlight.slash.circle", withConfiguration: largeConfig)
        let newImage: UIImage?
        if torchOn {
            newImage = torchOffImage
        }else{
            newImage = torchOnImage
        }
        UIView.transition(with: torchButton,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            self.torchButton.setImage(newImage, for: .normal)
        }, completion: nil)
    }
    private func setupScannerAnimation() {
        scannerAnimationView = .init(name: "scanner") // Your Lottie file name
        scannerAnimationView?.contentMode = .scaleAspectFit
        scannerAnimationView?.loopMode = .loop
        scannerAnimationView?.backgroundBehavior = .pauseAndRestore
        if let scannerView = scannerAnimationView {
            scannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(scannerView) 

            NSLayoutConstraint.activate([
                scannerView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
                scannerView.widthAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 1.2),
                scannerView.heightAnchor.constraint(equalTo: cameraView.heightAnchor, multiplier: 1.5),
                scannerView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor)
            ])
            scannerView.play()
        }
    }
    
    @IBAction func toruchButtonClicked(_ sender: Any) {
        torch.toggle()
        toogleTorch(torchOn: torch)
        cameraManager?.toggleTorch()
    }
    @IBAction func enterCodePressed(_ sender: Any) {
        let manualCodeVc = ManualCodeViewController()
        manualCodeVc.modalPresentationStyle = .fullScreen
        manualCodeVc.viewModel = ScanQrViewModel(networkManager: NetworkManager())
        navigationController?.pushViewController(manualCodeVc, animated: true)
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
