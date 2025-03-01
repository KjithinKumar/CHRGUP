//
//  OnboardingViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/02/25.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var pageController: UIPageControl!
    var viewModel : OnboardingViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.isNavigationBarHidden = true
        viewModel = OnboardingViewModel()

        configureUi()
        updateUi()

    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if viewModel?.moveToNextScreen() ?? false{
            self.imageView.transform = .identity
            self.imageView.alpha = 0.5

            updateUi()
            
            if viewModel?.isLastScreen ?? false {
                debugPrint(UserDefaults.standard.bool(forKey: AppConstants.isLoggedInKey))
            }
        } else {
            navigateToWelcomeScreen()
        }
    }
    @IBAction func skipButtonPressed(_ sender: Any) {
        navigateToWelcomeScreen()
    }
    @IBAction func previousButtonPressed(_ sender: Any) {
        if viewModel?.moveToPreviousScreen( ) ?? false {
            self.imageView.transform = .identity
            self.imageView.alpha = 0.5
            updateUi()
        }
    }
    
    func configureUi(){
        
        view.backgroundColor = ColorManager.backgroundColor
        
        titleLabel.font = FontManager.bold()
        titleLabel.textColor = ColorManager.textColor
        titleLabel.numberOfLines = 0
        
        
        descriptionLabel.font = FontManager.regular()
        descriptionLabel.textColor = ColorManager.subtitleTextColor
        descriptionLabel.numberOfLines = 0
        
        nextButton.backgroundColor = ColorManager.buttonColor
        nextButton.layer.cornerRadius = 30
        nextButton.tintColor = ColorManager.backgroundColor
        
        skipButton.tintColor = ColorManager.buttonColor
        skipButton.titleLabel?.font = FontManager.bold(size: 14)
        
        pageController.numberOfPages = viewModel?.screenCount ?? 3
        pageController.isUserInteractionEnabled = false
    }
    func updateUi(){
        
        let screen = viewModel?.currentScreen
        imageView.alpha = 1
        UIImageView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut){
            self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        pageController.currentPage = viewModel?.currentIndex ?? 0
        skipButton.isHidden = !(viewModel?.shouldShowSkip ?? true)
        previousButton.isHidden = !(viewModel?.shouldShowPrevious ?? true)
        UIView.transition(with: self.imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageView.image = screen?.image
        }, completion: nil)
        
        UIView.transition(with: self.titleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.titleLabel.text = screen?.title
        }, completion: nil)
        
        UIView.transition(with: self.descriptionLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.descriptionLabel.text = screen?.description
        }, completion: nil)
    }
    
    func navigateToWelcomeScreen(){
        let welcomeVc = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: welcomeVc)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}
