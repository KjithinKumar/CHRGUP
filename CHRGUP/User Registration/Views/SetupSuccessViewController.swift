//
//  SetupSuccessViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/03/25.
//

import UIKit
import Lottie

class SetupSuccessViewController: UIViewController {
    
    private var animationView2: LottieAnimationView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var animationView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpAnimation()
        
    }
    func setupUI() {
        view.backgroundColor = ColorManager.backgroundColor
        
        titleLabel.textColor = ColorManager.textColor
        titleLabel.font = FontManager.bold(size: 30)
        
        subtitleLabel.textColor = ColorManager.textColor
        subtitleLabel.font  = FontManager.regular()
    }
    
    func setUpAnimation() {
        //Load animation from a JSON file (name should match your Lottie file)
        animationView2 = LottieAnimationView(name: "tick_anim.json")
        
        guard let animationView2 = animationView2 else { return }
        
        animationView2.translatesAutoresizingMaskIntoConstraints = false
        animationView2.frame = animationView.bounds// Set size
        
        animationView2.contentMode = .scaleAspectFit // Adjust scaling
        animationView2.loopMode = .loop // Loop animation
        animationView2.animationSpeed = 1.0 // Set speed
        
        animationView.addSubview(animationView2)
        animationView.backgroundColor = ColorManager.backgroundColor
        NSLayoutConstraint.activate([
                    animationView2.topAnchor.constraint(equalTo: animationView.topAnchor),
                    animationView2.bottomAnchor.constraint(equalTo: animationView.bottomAnchor),
                    animationView2.leadingAnchor.constraint(equalTo: animationView.leadingAnchor),
                    animationView2.trailingAnchor.constraint(equalTo: animationView.trailingAnchor)
                ])
        animationView2.play() // Start animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let MapVc = MapScreenViewController()
            let navigationController = UINavigationController(rootViewController: MapVc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true)
            
        }
    }

}
