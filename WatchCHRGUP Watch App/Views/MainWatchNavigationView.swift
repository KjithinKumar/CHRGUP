//
//  MainWatchNavigationView.swift
//  WatchCHRGUP Watch App
//
//  Created by Jithin Kamatham on 22/06/25.
//

import SwiftUI

struct MainWatchNavigationView: View {
    var body: some View {
        NavigationStack{
            List{
                NavigationLink(destination: NearByChargersView(ViewModel: NearByChargerViewModel(networkManager: NetworkManager()))){
                    HStack {
                        Image(systemName: "map.fill")
                            .font(.title2) // Larger icon
                            .foregroundStyle(.blue)
                            .frame(width: 40) // Fixed width for alignment
                        VStack(alignment: .leading) {
                            Text("Nearby Chargers")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Text("Find stations around you")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 8)
                }
                NavigationLink(destination: EnterChargerView(viewModel: ScanQrViewModel(networkManager: NetworkManager()))){
                    HStack {
                        Image(systemName: "bolt.fill")
                            .font(.title2) // Larger icon
                            .foregroundStyle(.green)
                            .frame(width: 40) // Fixed width for alignment
                        
                        VStack(alignment: .leading) {
                            Text("Start Charging")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Text("Enter code to start charge")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 8) // More vertical padding
                }
            }.padding(.top, 10)
            .navigationTitle(Text("CHRGUP"))
        }
    }
}

#Preview {
    MainWatchNavigationView()
}
