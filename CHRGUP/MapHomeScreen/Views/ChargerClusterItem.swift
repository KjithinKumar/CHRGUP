//
//  ChargerClusterItem.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 05/04/25.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils

class ChargerClusterItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var chargers: ChargerRangeModel?
    
    init(position: CLLocationCoordinate2D, chargers: ChargerRangeModel?) {
        self.position = position
        self.chargers = chargers
    }
}
