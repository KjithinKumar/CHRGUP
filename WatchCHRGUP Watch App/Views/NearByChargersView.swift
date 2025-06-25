//
//  NearByChargersView.swift
//  WatchCHRGUP Watch App
//
//  Created by Jithin Kamatham on 22/06/25.
//

import SwiftUI
import CoreLocation

struct NearByChargersView: View {
    var ViewModel : NearByChargerViewModelInterface
    @State var locations: [LocationData] = []
    
    var body: some View {
        NavigationStack {
            if locations.isEmpty {
                VStack(alignment: .center) {
                    ProgressView()
                        .tint(.green)
                    Text("Loading...")
                }
            }else{
                List(locations) { charger in
                    NavigationLink(destination: LocationDetailView(location: charger)) {
                        VStack(alignment: .leading){
                            Text(charger.locationName)
                                .font(.headline)
                                .foregroundStyle(Color.white)
                                .padding(.top, 10)
                            if let points = charger.modpointsAvailable {
                                HStack{
                                    if points != 0 {
                                        Image (systemName: "bolt.fill")
                                            .foregroundColor(.green)
                                        Text ("\(points) points available")
                                            .font(.caption)
                                            .foregroundStyle(.green)
                                    }else{
                                        Image(systemName: "bolt.fill")
                                            .foregroundColor(.gray)
                                        Text("\(points) points available")
                                            .font(.caption)
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                HStack{
                                    if let locationStatus = charger.modLocationAvailble {
                                        if locationStatus{
                                            Text("OPEN")
                                                .font(.caption)
                                                .foregroundStyle(.green)
                                        }else{
                                            Text("CLOSED")
                                                .font(.caption)
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    Spacer()
                                    if let distance = charger.modDistance {
                                        Text("\(distance) Kms")
                                            .font(.caption)
                                    }
                                }.padding(.bottom, 10)
                                    .padding(.top ,10)
                            }
                        }
                    }
                }
            }
        }.navigationBarTitle(Text("Nearby Chargers"))
            .onAppear {
                self.fetchNearByCharger()
            }
            .onReceive(WatchSessionManager.shared.$userLocation) { location in
                    if let loc = location, loc.count == 2 {
                        fetchNearByCharger()
                    }
                }
    }
    func fetchNearByCharger() {
        let currentLocation = WatchSessionManager.shared.userLocation
        let location = CLLocation(latitude: currentLocation?.first ?? 0.0, longitude: currentLocation?.last ?? 0.0)
        let lat = currentLocation?.first ?? 0.0
        let long = currentLocation?.last ?? 0.0
        let mobileNumber = UserDefaultManager.shared.getUserProfile()?.phoneNumber ?? ""
        ViewModel.getNearByCharger(latitue: lat, longitude: long, range: 25000, mobileNumber: mobileNumber) { result in
            switch result {
            case .success(_) :
                self.locations = ViewModel.sortedNearByChargerData(currentLocation: location)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}

#Preview {
    NearByChargersView(ViewModel: NearByChargerViewModel(networkManager: NetworkManager()))
}
