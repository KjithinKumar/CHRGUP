//
//  StartCharge.swift
//  WatchCHRGUP Watch App
//
//  Created by Jithin Kamatham on 22/06/25.
//

import SwiftUI

struct StartCharge: View {
    var viewModel : StartChargeViewModelInterface
    var qrPayload : QRPayload?
    @State var showAlert : Bool = false
    @State var alertMessage : String = ""
    @State var isLoading : Bool = false

    var body: some View {
        ScrollView{
            HStack{
                Text("Name")
                    .foregroundStyle(Color.gray)
                Spacer()
                let name = viewModel.chargerDetails?.chargerInfo?.name
                Text(name ?? "DEMO1")
            }
            HStack {
                Text("Location")
                    .foregroundStyle(Color.gray)
                Spacer()
                let location = viewModel.chargerDetails?.location?.locationName
                Text(location ?? "Proms Complex")
            }
            HStack{
                Text("Type")
                    .foregroundStyle(Color.gray)
                Spacer()
                let type = (viewModel.chargerDetails?.chargerInfo?.type ?? "ac") + " - " + (viewModel.chargerDetails?.chargerInfo?.powerOutput ?? "7.4")
                Text(type)
            }
            HStack {
                Text("Charging Tariff")
                    .foregroundStyle(Color.gray)
                Spacer()
                let chargingTariff = viewModel.chargerDetails?.location?.freePaid?.charging
                Text(chargingTariff ?? true ? "FREE" : "PAID")
            }
            HStack{
                Text("Parking Tariff")
                    .foregroundStyle(Color.gray)
                Spacer()
                let parkingTariff = viewModel.chargerDetails?.location?.freePaid?.parking
                Text(parkingTariff ?? false ? "FREE" : "PAID")
            }
            HStack {
                Text("Cost per Unit")
                    .foregroundStyle(Color.gray)
                Spacer()
                let costPerUnit = viewModel.chargerDetails?.chargerInfo?.costPerUnit?.amount
                let curreny = viewModel.chargerDetails?.chargerInfo?.costPerUnit?.currency
                let amount = "\(costPerUnit ?? 0.00) \(curreny ?? "INR")"
                Text(amount)
            }
            Spacer(minLength: 10)
            if isLoading{
                ProgressView()
                    .tint(Color.green)
            }else{
                Button{
                    isLoading = true
                    startCharge()
                    
                }label: {
                    Text("start charge")
                }.foregroundStyle(Color.green)
            }
        }.alert("Alert", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
            Button("Cancel", role: .destructive){ }
        }message: {
            Text(alertMessage)
        }
    }
    func startCharge() {
        guard let qrPayload = qrPayload else {
            return
        }
        guard let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber else {
            return
        }
        viewModel.startCharging(phoneNumber: mobileNumber, qrpayload: qrPayload) {result in
            isLoading = false
            switch result {
            case .success(let response):
                if response.status{
                    WatchSessionManager.shared.sendDataToIphone()
                    DispatchQueue.main.async {
                        WatchSessionManager.shared.isSesssionActive(isActive: true)
                    }
                }else{
                    alertMessage = response.message ?? "Something went wrong"
                    showAlert.toggle()
                }
                
            case .failure(let error):
                alertMessage = error.localizedDescription
                showAlert.toggle()
            }
        }
    }
}

#Preview {
    //StartCharge()
}
