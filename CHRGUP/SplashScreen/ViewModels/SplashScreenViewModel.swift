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
        checkLatestVersion { [weak self] isForcedUpdate, updateUrl in
            guard let url = updateUrl else {return}
            //Calculate how long version check took
            let versionCheckTime = Date().timeIntervalSince1970 - startTime
            let leftTime = max(0, AppConstants.splashScreenInterval - versionCheckTime)
            DispatchQueue.main.asyncAfter(deadline: .now() + leftTime) {
                if isForcedUpdate{
                    self?.delegate?.showUpdateDialog(url: url) //Notify User to Force Update
                    //return
                }else {
                    self?.checkOnboardingStatus()// Check login
                }
            }
        } 
    }
    
    //Checking the latest version
    private func checkLatestVersion(completion: @escaping (Bool,String?)->(Void)){
        let request = networkManager?.createRequest(
            urlString: URLs.checkVersionUrl,
            method: .get,
            body: nil,
            encoding: .json,
            headers: nil)
        if let request = request{
            networkManager?.request(request, decodeTo: VersionResponseModel.self, completion: { [weak self] result in
                guard let _ = self else { return }
                switch result{
                case .success(let versionResponse) :
                    if !versionResponse.status, versionResponse.force {
                        debugPrint(versionResponse.iPhoneUrl ?? "no value")
                        completion(true, versionResponse.iPhoneUrl)
                    } else {
                        completion(false, "nil")
                    }
                case .failure(let error) :
                    //error
                    debugPrint(error)
                    return
                }
            })
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
