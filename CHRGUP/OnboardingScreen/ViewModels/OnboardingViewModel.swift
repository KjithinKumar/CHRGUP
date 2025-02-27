//
//  OnboardingViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 26/02/25.
//

import Foundation
import UIKit

class OnboardingViewModel {
    private let screens = [OnboardingModel(title: AppStrings.Onboarding.onboardingTitleOne,
                                           description: AppStrings.Onboarding.onboardingSubtitleOne,
                                           image: UIImage(named: AppStrings.Onboarding.onboardingImageOne)!),
                           OnboardingModel(title: AppStrings.Onboarding.onboardingTitleTwo,
                                           description: AppStrings.Onboarding.onboardingSubtitleTwo,
                                           image: UIImage(named: AppStrings.Onboarding.onboardingImageTwo)!),
                           OnboardingModel(title: AppStrings.Onboarding.onboardingTitleThree,
                                           description: AppStrings.Onboarding.onboardingSubtitleThree,
                                           image: UIImage(named: AppStrings.Onboarding.onboardingImageThree)!)
    ]
    private var currentIndex = 0
    
    var screenCount: Int {
        return screens.count
    }
    
    var currentScreen: OnboardingModel {
        return screens[currentIndex]
    }
    
    var isLastScreen: Bool {
        return currentIndex == screens.count - 1
    }
    
    var isFirlstScreen: Bool {
        return currentIndex == 0
    }
    
    var shouldShowPrevious: Bool {
        return currentIndex > 0
    }
    
    var shouldShowSkip: Bool {
        return currentIndex < screens.count - 1
    }
    
    func moveToNextScreen() -> Bool {
        guard currentIndex < screens.count - 1 else { return false }
        currentIndex += 1
        return true
    }
    
    func moveToPreviousScreen() -> Bool {
        guard currentIndex > 0 else { return false }
        currentIndex -= 1
        return true
    }
    
    func reset() {
        currentIndex = 0
    }
}
