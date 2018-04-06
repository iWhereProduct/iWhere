//
//  LocationOperations.swift
//  IWHERE
//
//  Created by Михаил on 04.12.2017.
//  Copyright © 2017 WorldCitizien. All rights reserved.
//

import Foundation
import CoreLocation

class LocationOperations:NSObject, CLLocationManagerDelegate{
    
    private let manager = CLLocationManager()
    
    public func getLocation() -> String?{
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            manager.startUpdatingLocation()
            if manager.location != nil {
                let coords = "\(manager.location!.coordinate.latitude)-\(manager.location!.coordinate.longitude)"
                manager.stopUpdatingLocation()
                return coords
            }
        }
        return "Nothing"
    }
    
    public func getCLLocation() -> CLLocationCoordinate2D? {
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            manager.startUpdatingLocation()
            if manager.location != nil {
                let coords2D = manager.location!.coordinate
                manager.stopUpdatingLocation()
                return coords2D
            }
        }
        return nil
    }
}
