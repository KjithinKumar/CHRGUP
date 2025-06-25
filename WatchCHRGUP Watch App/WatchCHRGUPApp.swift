//
//  WatchCHRGUPApp.swift
//  WatchCHRGUP Watch App
//
//  Created by Jithin Kamatham on 21/06/25.
//

import SwiftUI

@main
struct WatchCHRGUP_Watch_AppApp: App {
    @StateObject private var sessionManager = WatchSessionManager.shared
    var body: some Scene {
        WindowGroup {
            if sessionManager.isLoggedIn {
                if sessionManager.isSessionActive {
                    ChargingStatusView(viewModel: ChargingStatusViewModel(networkManager: NetworkManager()))
                }else{
                    MainWatchNavigationView()
                }
            }else{
             LoginView()
            }
        }
    }
}
