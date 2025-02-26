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
        //Animate the logo
        UIView.animate(withDuration: 1.2, delay: 0, options: .curveEaseInOut){
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        gridImageView.tintColor = .label
    }
}
extension SplashScreenViewController : SplashViewModelDelegate{
    func navigateToMain() {
        //Navigate to Main
    }
    
    func navigateToOnboarding() {
        //Navigate to OnBoarding
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
