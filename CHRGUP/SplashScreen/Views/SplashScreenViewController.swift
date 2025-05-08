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
        viewModel?.startSplashProcess()
    }
    private func setUp(){
        logoImageView.startShimmering()
        gridImageView.tintColor = ColorManager.textColor
        view.backgroundColor = ColorManager.backgroundColor
    }
}
extension SplashScreenViewController : SplashViewModelDelegate{
    func navigateToMain() {
       let welcomeVc = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
        navigationController?.setViewControllers([welcomeVc], animated: true)
    }
    
    func navigateToOnboarding() {
        let onboardingVC = OnboardingViewController(nibName: "OnboardingViewController", bundle: nil)
        navigationController?.navigationBar.isHidden = true
        navigationController?.setViewControllers([onboardingVC], animated: true)
    }
    func navigateToMap() {
        let MapVc = MapScreenViewController()
        MapVc.viewModel = MapScreenViewModel(networkManager: NetworkManager())
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
}
