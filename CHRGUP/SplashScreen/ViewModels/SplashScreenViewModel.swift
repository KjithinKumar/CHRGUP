//
//  splashScreenViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 25/02/25.
//

import Foundation
import UIKit

protocol SplashViewModelDelegate: AnyObject {
    func navigateToMain()
    func navigateToOnboarding()
    func navigateToMap()
    func showUpdateDialog(url: String?)
    func showError(error : Error)
}

class SplashScreenViewModel{
    weak var delegate : SplashViewModelDelegate?
    var networkManager : NetworkManagerProtocol?
    
    init(networkManager : NetworkManagerProtocol,delegate : SplashViewModelDelegate){
        self.delegate = delegate
        self.networkManager = networkManager
        NotificationCenter.default.addObserver(self, selector: #selector(handleInternetRestored), name: .internetRestored, object: nil) //Internet Restored Observer
    }
    
    //Start the Splash process
    func startSplashProcess(){
        let startTime = Date().timeIntervalSince1970
        checkLatestVersion { [weak self] result in
            let versionCheckTime = Date().timeIntervalSince1970 - startTime
            let leftTime = max(0, AppConstants.splashScreenInterval - versionCheckTime)
            guard let self = self else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + leftTime){
                switch result{
                case .success(let response):
                    if !response.status && response.force{
                        self.delegate?.showUpdateDialog(url: response.iPhoneUrl)
                    }else{
                        self.checkOnboardingStatus()
                    }
                case .failure(let error):
                    self.delegate?.showError(error: error)
                }
            }
        }
    }
    
    //Checking the latest version
    func checkLatestVersion(completion : @escaping (Result<VersionResponseModel, Error>)-> Void){
        if let request = networkManager?.createRequest(urlString: URLs.checkVersionUrl, method: .get, body: nil, encoding: .json, headers: nil){
            networkManager?.request(request, decodeTo: VersionResponseModel.self) { result in
                completion(result)
            }
        }
    }
    
    //Checking Login Status
    private func checkOnboardingStatus() {
        let isOnboarded = UserDefaultManager.shared.isOnboardingCompleted()
        if  isOnboarded{
            checkLoginStatus()
        } else {
            delegate?.navigateToOnboarding()
        }
    }
    private func checkLoginStatus() {
        let isLoggedIn = UserDefaultManager.shared.isLoggedIn()
        if isLoggedIn{
            delegate?.navigateToMap()
        }else{
            delegate?.navigateToMain()
        }
        
    }
    
    @objc func handleInternetRestored(){
        //If splash screen is visible continue with process
        if UIApplication.shared.getCurrentViewController() is SplashScreenViewController {
            startSplashProcess()
        }
        
    }
}
