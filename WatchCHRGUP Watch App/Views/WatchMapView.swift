//
//  WatchMapView.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 24/06/25.
//


import SwiftUI
import MapKit // Import MapKit for CLLocationCoordinate2D

struct WatchMapView: View {
    let locationName: String
    let latitude: Double
    let longitude: Double

    var body: some View {
        VStack {
            // Display a small map preview within your app
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01),
                
            ))){
                Marker(locationName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                    .tint(.red)
            }
            .frame(height: 100) // Adjust height as needed
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 5)

            // Button to open the native Apple Maps app
            Button("Open in Maps") {
                openNativeMaps()
            }
            .foregroundStyle(.blue)
            .font(.caption2)
            .padding(.horizontal)
        }
        .navigationTitle(locationName)
    }

    private func openNativeMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = locationName // Optional: give the pin a name

        // Open in Apple Maps
        mapItem.openInMaps(launchOptions: nil)
    }
}

