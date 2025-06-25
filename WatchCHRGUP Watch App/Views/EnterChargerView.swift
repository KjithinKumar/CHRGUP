//
//  EnterChargerView.swift
//  WatchCHRGUP Watch App
//
//  Created by Jithin Kamatham on 21/06/25.
//

import SwiftUI

struct EnterChargerView: View {
    @State private var chargerId = ""
    @State private var showAlert = false
    @State private var isLoading: Bool = false
    @State private var alertMessage = ""
    @State private var navigateToStartCharge = false
    @State private var connecterId: String = ""
    @State var chargerLocationData : ChargerLocationData?
    var viewModel: ScanQrViewModelInterface
    @State private var qrPayload : QRPayload?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Enter Charger ID")
                    .font(.headline)
            }
            TextField("Charger ID", text: $chargerId)
                .textCase(.uppercase)
                .foregroundStyle(.green)
            HStack {
                Text("Connecter Id : ")
                    .font(.caption)
                    .minimumScaleFactor(0.8)
                TextField("ID", text: $connecterId)
                    .textCase(.uppercase)
                    .foregroundStyle(.green)
            }
            if isLoading {
                ProgressView()
                    .tint(.green)
            }else {
                Button("Submit"){
                    submitCode()
                }.foregroundStyle(Color.green)
            }
        }.navigationDestination(isPresented: $navigateToStartCharge) {
            if let data = chargerLocationData {
                StartCharge(viewModel: StartChargeViewModel(chargerInfo: data, networkManager: NetworkManager()),qrPayload: qrPayload)
            }
        }
        .alert("Alert", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
            Button("Cancel", role: .destructive){ }
        }
        message: {
            Text(alertMessage)
        }
    }
    func submitCode() {
        isLoading = true
        let cleanedCode = chargerId.replacingOccurrences(of: " ", with: "").uppercased()
        let Id = Int(connecterId) ?? 1
        qrPayload = QRPayload(connectorId: Id, chargerId: cleanedCode)
        viewModel.fetchChargerDetails(id: cleanedCode, connectorId: Id) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if response.status, let data = response.data {
                        navigateToStartCharge = true
                        WatchSessionManager.shared.sendDataToIphone()
                        self.chargerLocationData = data
                    } else {
                        chargerId = ""
                        connecterId = ""
                        alertMessage = response.message ?? "error finding the charger code"
                        showAlert = true
                    }
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}


#Preview {
    EnterChargerView(viewModel: ScanQrViewModel(networkManager: NetworkManager()))
}
