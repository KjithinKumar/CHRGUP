//
//  ChargingStatusView.swift
//  WatchCHRGUP Watch App
//
//  Created by Jithin Kamatham on 22/06/25.
//

import SwiftUI

struct ChargingStatusView: View {
    @State private var energyConsumed: String = "0.0000 kWh"
    @State private var chargingTimeFormatted: String = "00 h : 00 m"
    @State private var pricePerUnit: String = "₹ 0.00/Unit"
    @State private var lastPingStatus: String = "Last Ping: Never"
    @State private var isLoadingStopCharge: Bool = false
    @State private var showingStopConfirmation: Bool = false
    @State private var showAlert: Bool = false
    @State private var statusAlertMessage: String = ""
    @State private var showPayenergyAlert: Bool = false
    @State private var paymentMessage : String = ""
    @State private var lastPingDate: Date?
    @State private var chargingSessionStartDate: Date = Date()

    let fetchTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    let updateLabelTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var viewModel : ChargingStatusViewModelInterface
    var body: some View {
        VStack{
            Text("Charging Progress")
                .foregroundStyle(Color.green)
                .lineLimit(1)
                .font(.title3)
                .padding(.top,-15)
            VStack{
                Text("Power Consumed")
                    .foregroundStyle(.gray)
                Text(energyConsumed)
                    .foregroundStyle(Color.white)
                    .font(.title2)
            }
            VStack{
                Text("Time Consumed")
                    .foregroundStyle(.gray)
                
                Text(chargingTimeFormatted)
                    .foregroundStyle(Color.white)
                    .font(.title2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            HStack{
                Spacer()
                Text(lastPingStatus)
                    .foregroundStyle(Color.gray)
                    .font(.footnote)
            }
            if isLoadingStopCharge{
                ProgressView()
                    .tint(Color.green)
            }else{
                Button{
                    showingStopConfirmation = true
                }label: {
                    Text("Stop Charging")
                }.foregroundStyle(.red)
            }
        }.onReceive(fetchTimer) { _ in
            fetchData()
            
        }.onReceive(updateLabelTimer) { _ in
            updateLastPingLabel()
            updateChargingTimeLabel()
        }.alert("Stop Charging", isPresented: $showingStopConfirmation) {
            Button("Yes, Stop", role: .destructive) {
                stopChargingSession()
            }
            Button("Cancel", role: .cancel) { }
        }message: {
            Text("Are you sure you want to end your charging session?")
        }
        .alert("Alert", isPresented: $showAlert) {
            Button("Ok", role: .cancel){}
            Button("Cancel", role : .destructive){}
        }message: {
            Text(statusAlertMessage)
        }
        .alert("Charging Completed", isPresented: $showPayenergyAlert) {
            Button("Ok", role: .cancel){
                DispatchQueue.main.async {
                    WatchSessionManager.shared.isSesssionActive(isActive: false)
                }
            }
            Button("Cancel", role : .destructive){
                DispatchQueue.main.async {
                    WatchSessionManager.shared.isSesssionActive(isActive: false)
                }
            }
        }message: {
            Text("Complete the payment using mobile App.")
        }
        
    }
    func fetchData(){
        viewModel.fetchChargingStatus { result in
            switch result {
            case .success(let response):
                if response.status{
                    if let chargingStatus = response.data{
                        self.energyConsumed = convertWhToKWh(chargingStatus.meterValueDifference)
                        self.pricePerUnit = "₹ \(chargingStatus.costPerUnit?.amount ?? 0)/Unit"
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.timeZone = TimeZone.current
                        if let apiStartTime = dateFormatter.date(from: chargingStatus.startTimeIST ?? "") {
                            self.chargingSessionStartDate = apiStartTime
                        }
                        self.chargingTimeFormatted = self.getFormattedTimeDifference(from: self.chargingSessionStartDate)
                        self.lastPingDate = Date()
                        UserDefaultManager.shared.saveSessionStatus(chargingStatus.status)
                        WatchSessionManager.shared.sendDataToIphone()
                    }
                                            
                }else{
                    statusAlertMessage = response.message ?? "Something went wrong"
                    showAlert = true
                    WatchSessionManager.shared.isSesssionActive(isActive: false)
                }
            case .failure(let error):
                statusAlertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    func stopChargingSession(){
        viewModel.stopCharging { result in
            switch result {
            case .success(let response):
                if response.status{
                    showPayenergyAlert = true
                }else{
                    statusAlertMessage = response.message ?? "Something went wrong"
                    showAlert = true
                }
            case .failure(let error):
                statusAlertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    private func updateLastPingLabel() {
            guard let lastPing = lastPingDate else {
                lastPingStatus = "Last Ping: Never"
                return
            }
            let secondsAgo = Int(Date().timeIntervalSince(lastPing))
            lastPingStatus = "Last Ping: \(secondsAgo)s ago"
        }

        private func updateChargingTimeLabel() {
            self.chargingTimeFormatted = self.getFormattedTimeDifference(from: self.chargingSessionStartDate)
        }

        private func convertWhToKWh(_ whString: String) -> String {
            let trimmed = whString.replacingOccurrences(of: "Wh", with: "").trimmingCharacters(in: .whitespaces)
            guard let wattHours = Double(trimmed) else {
                return "Invalid input"
            }
            let kilowattHours = wattHours / 1000
            return String(format: "%.4f kWh", kilowattHours)
        }

        private func getFormattedTimeDifference(from pastDate: Date) -> String {
            let currentDate = Date()
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: pastDate, to: currentDate)

            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0
            let seconds = components.second ?? 0

            return String(format: "%02dh:%02dm:%02d s", hours, minutes, seconds)
        }
}

#Preview {
    ChargingStatusView(viewModel: ChargingStatusViewModel(networkManager: NetworkManager()))
}
