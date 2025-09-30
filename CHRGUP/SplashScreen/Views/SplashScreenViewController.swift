//
//  SplashScreenViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import UIKit

class SplashScreenViewController: UIViewController {
    var viewModel : SplashScreenViewModel?
    @IBOutlet weak var gridImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    private func setUp(){
        logoImageView.startShimmering()
        viewModel?.startSplashProcess()
    }
}
extension SplashScreenViewController : SplashViewModelDelegate{
    func navigateToMain() {
       let welcomeVc = WelcomeViewController()
        navigationController?.setViewControllers([welcomeVc], animated: true)
    }
    func navigateToOnboarding() {
        let onboardingVC = OnboardingViewController()
        navigationController?.navigationBar.isHidden = true
        navigationController?.setViewControllers([onboardingVC], animated: true)
    }
    func navigateToMap() {
        let status = UserDefaultManager.shared.IsSessionActive()
        if status{
            viewModel?.fetchChargingStatus { [weak self] result  in
                guard let _ = self else {return}
                switch result{
                case .success(let response):
                    let status = response.data?.status
                    UserDefaultManager.shared.saveSessionStatus(status)
                case .failure(_) : break
                }
            }
        } 
        let MapVc = MapScreenViewController()
        MapVc.viewModel = MapScreenViewModel(networkManager: NetworkManager.shared)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = ColorManager.secondaryBackgroundColor
        appearance.titleTextAttributes = [.foregroundColor: ColorManager.textColor]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.setViewControllers([MapVc], animated: true)
    }
    
    func showUpdateDialog(url: String?) {
        showAlert(title: AppStrings.Alert.updateTitle,
                  message: AppStrings.Alert.updateMessage,
                  style: .alert,
                  actions: [UIAlertAction(title: AppStrings.Alert.update, style: .default) { _ in
            if let urlString = url, let updateURL = URL(string: urlString) {
                UIApplication.shared.open(updateURL)
            }
        }]
        )
    }
    func showError(error: Error) {
        logoImageView.stopShimmering()
        let action = UIAlertAction(title: "Retry", style: .default){ _ in
            self.setUp()
        }
        switch error as? NetworkManagerError{
        case .serverError(let message , _):
            showAlert(title: "Error", message: message, actions: [action])
        default :
            showAlert(title: "Error", message: error.localizedDescription,style: .alert,actions: [action])
        }
    }
}
