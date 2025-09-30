//
//  KYCViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 15/09/25.
//

import Foundation

protocol KYCViewModelInterface{
    var documentTypes : [DocumentTypes] {get}
}

class KYCViewModel : KYCViewModelInterface{
    var networkManager : NetworkManagerProtocol
    var documentTypes = [DocumentTypes.panCard,DocumentTypes.drivingLicense,DocumentTypes.voterId]
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
}
