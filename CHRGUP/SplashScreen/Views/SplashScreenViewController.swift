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
        
        let navigationController = UINavigationController(rootViewController: welcomeVc)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.tintColor = ColorManager.buttonColorwhite
        present(navigationController, animated: true, completion: nil)
    }
    
    func navigateToOnboarding() {
        let onboardingVC = OnboardingViewController(nibName: "OnboardingViewController", bundle: nil)
        onboardingVC.modalPresentationStyle = .fullScreen
       present(onboardingVC, animated: true, completion: nil)
    }
    func navigateToMap() {
        let MapVc = MapScreenViewController()
        MapVc.viewModel = MapScreenViewModel()
        let navigationController = UINavigationController(rootViewController: MapVc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
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
