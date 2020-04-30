//
//  CoordinateRegionExtension.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 16/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation
import MapKit

internal extension MKCoordinateRegion {
    static func fromDictionary(_ input: Any?) -> MKCoordinateRegion? {
        if input == nil || !(input! is NSDictionary) {
            return nil
        }
        
        let dict = input! as! NSDictionary
        
        let southWest = CLLocationCoordinate2D.fromDictionary(coordinateDict: dict["southWest"] as! NSDictionary)
        let northEast = CLLocationCoordinate2D.fromDictionary(coordinateDict: dict["northEast"] as! NSDictionary)

        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (northEast.latitude + southWest.latitude) / 2.0, longitude: (northEast.longitude + southWest.longitude) / 2.0),
                                  span: MKCoordinateSpan(latitudeDelta: abs(northEast.latitude - southWest.latitude), longitudeDelta: abs(northEast.longitude - southWest.longitude)))
    }
}

internal extension CLLocationCoordinate2D {
    static func fromDictionary(coordinateDict: NSDictionary) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: (coordinateDict["lat"] as! NSNumber).doubleValue,
            longitude: (coordinateDict["lng"] as! NSNumber).doubleValue
        )
    }
}
