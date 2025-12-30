//
//  LocationHelper.swift
//  Solid
//
//  Created by Solid iOS Team on 9/11/19.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

enum LocationStatus: Int {
    case allowed,
    waiting,
    denied
}

class LocationHelper: NSObject {
    static let shared = LocationHelper()

    var locationManager: CLLocationManager!

    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var checkLocationEnable = Bool()
    var updatingLocWithCompletionHandler: ((_ status: LocationStatus, _ latitude: Double, _ longitude: Double, _ error: Error?) -> Void)?
    
    func isLocationEnable() -> Bool {
        self.checkLocationPermission()
        return checkLocationEnable
    }
    
    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                checkLocationEnable = true
                startUpdatingLocation()
            case .denied, .restricted:
                checkLocationEnable = false
                self.updatingLocWithCompletionHandler?(.denied, latitude, longitude, nil)
                locationPermissionAlert()
            case .notDetermined:
                checkLocationEnable = false
                self.updatingLocWithCompletionHandler?(.waiting, latitude, longitude, nil)
               requestLocationPermission()
            @unknown default:
                break
            }
        } else {
            // Is not enable
            checkLocationEnable = false
            self.updatingLocWithCompletionHandler?(.denied, latitude, longitude, nil)
            locationPermissionAlert()
        }
    }

    func locationPermissionCheckOnAppMode() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.updatingLocWithCompletionHandler?(.allowed, latitude, longitude, nil)
            case .denied, .restricted:
                self.updatingLocWithCompletionHandler?(.denied, latitude, longitude, nil)
            case .notDetermined:
                self.updatingLocWithCompletionHandler?(.waiting, latitude, longitude, nil)
            @unknown default:
                break
            }
        } else {
            // Is not enable
            self.updatingLocWithCompletionHandler?(.denied, latitude, longitude, nil)
            debugPrint("Location service is not enabled")
        }
    }

    func initLocationManager() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            
        }
    }

    func requestLocationPermission() {
        initLocationManager()
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func startUpdatingLocation() {
        initLocationManager()
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        locationManager = nil
    }

    func locationPermissionAlert() {

        let alert = UIAlertController(title: Utility.localizedString(forKey: "location_permission_title"), message: Utility.localizedString(forKey: "location_permission"), preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            Utility.openSettigsApp()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        let aKeyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        aKeyWindow?.rootViewController?.present(alert, animated: true, completion: nil)

    }
}

// MARK: - Location Manager Delegate
extension LocationHelper: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(location.latitude) \(location.longitude)")
        latitude = location.latitude
        longitude = location.longitude

        self.updatingLocWithCompletionHandler?(.allowed, latitude, longitude, nil)
        self.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        latitude = 0.0
        longitude = 0.0
        self.updatingLocWithCompletionHandler?(.denied, latitude, longitude, error)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        latitude = 0.0
        longitude = 0.0
        self.checkLocationPermission()
    }
}

// MARK: - Address
extension LocationHelper {

    func getLatLongFromAddress(_ address: String, completion : @escaping (CLLocationCoordinate2D?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, _) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    completion(nil)
                    return
            }

            let coordinates: CLLocationCoordinate2D = location.coordinate
            self.latitude = coordinates.latitude
            self.longitude = coordinates.longitude
            completion(coordinates)
        }
    }
}
