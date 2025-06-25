//
//  LocationDetailView.swift
//  WatchCHRGUP Watch App
//
//  Created by Jithin Kamatham on 24/06/25.
//

import SwiftUI
import SDWebImage

struct LocationDetailView: View {
    let location : LocationData
    @State private var connectorItems : [ConnectorDisplayItem] = []
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                Text(location.locationName)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("\(location.modDistance ?? "0") Kms away")
                    .font(.caption)
                if let status = location.modLocationAvailble {
                    if status {
                        Text("OPEN")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }else{
                        Text("CLOSED")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                LinearGradient(gradient: Gradient(colors: [.green,.gray,.white,.green]), startPoint: .leading, endPoint: .trailing)
                    .frame(height: 1)
                HStack{
                    Spacer()
                    if let points = location.modpointsAvailable {
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
                }
                TabView {
                    if !connectorItems.isEmpty{
                        ForEach(connectorItems) { item in
                            let chargerInfo = item.chargerInfo
                            let connector = item.connector
                            let type = chargerInfo.type ?? "unkown"
                            let subType = chargerInfo.subType ?? "Unknown"
                            let powerOutput = chargerInfo.powerOutput ?? "Unknown"
                            let name = "\(type) \(powerOutput)"
                            let status = item.connector.status
                            let imageName = getImageName(for: subType, status: status)
                            let statusColor: Color = {
                                let status = connector.status
                                if status == "Available"{
                                    return .green
                                }else if status == "Inactive"{
                                    return .gray
                                }else{
                                    return.blue
                                }
                            }()
                            VStack() {
                                let chargerName = chargerInfo.name ?? "Unknown"
                                Text(chargerName)
                                    .font(.caption)
                                    .foregroundColor(statusColor)
                                let connectorId = connector.connectorId
                                Text(" Connector ID: \(connectorId)")
                                    .font(.caption)
                                    .foregroundStyle(statusColor)
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(statusColor)
                                Text(name)
                                    .font(.caption)
                                    .foregroundColor(statusColor)
                                Text(status)
                                    .font(.caption)
                                    .foregroundStyle(statusColor)
                            }
                        }
                    }
                }.tabViewStyle(.page)
                    .frame(height: 150)
                LinearGradient(gradient: Gradient(colors: [.green,.gray,.white,.green]), startPoint: .leading, endPoint: .trailing)
                    .frame(height: 1)
                Text("Address")
                    .font(.title2)
                    .foregroundStyle(.white)
                Text(location.address)
                    .font(.caption)
                    .foregroundStyle(.gray)
                WatchMapView(locationName: location.locationName, latitude: location.direction.latitude, longitude: location.direction.longitude)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                loadConnectors()
            }
        
    }
    func loadConnectors(){
        let chargerData = location.chargerInfo
        for charger in chargerData{
            if let connectors = charger.connectors{
                for connector in connectors{
                    connectorItems.append(ConnectorDisplayItem(chargerInfo: charger, connector: connector))
                }
            }
        }
        let statusPriority: [String: Int] = ["Available": 0, "Inactive": 2]
        connectorItems = connectorItems.sorted {
            (statusPriority[$0.connector.status] ?? 1) < (statusPriority[$1.connector.status] ?? 1)
        }
    }
    func getImageName(for subType: String, status: String) -> String {
        if subType == "CCS2" {
            if status == "Available" {
                return "CCS2available"
            }else if status == "Inactive"{
                return "CCS2inactive"
            }else{
                return "CCS2inuse"
            }
        }else if subType == "Type6" {
            if status == "Available" {
                return "Type6available"
            }else if status == "Inactive"{
                return "Type6inactive"
            }else{
                return "Type6inuse"
            }
        }else{
            if status == "Available" {
                return "Type7available"
            }else if status == "Inactive"{
                return "Type7inactive"
            }else{
                return "Type7inuse"
            }
        }
    }
}

#Preview {

}
