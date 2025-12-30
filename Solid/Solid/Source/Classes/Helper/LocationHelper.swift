//
//  LocationHelper.swift

//  Superbank
//
//  Created by rohan on 08/02/21.
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

    var address: Address!

    var updatingLocWithCompletionHandler: ((_ status: LocationStatus, _ latitude: Double, _ longitude: Double, _ error: Error?) -> Void)?

    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                debugPrint("Location service is enabled")
                startUpdatingLocation()
            case .denied, .restricted:
                debugPrint("Location service is denied/restricted")
                self.updatingLocWithCompletionHandler?(.denied, latitude, longitude, nil)
                locationPermissionAlert()
            case .notDetermined:
                debugPrint("Location service is not Determined")
                self.updatingLocWithCompletionHandler?(.waiting, latitude, longitude, nil)
                requestLocationPermission()
            @unknown default:
                debugPrint("Scope for any new case")
            }
        } else {
            // Is not enable
            self.updatingLocWithCompletionHandler?(.denied, latitude, longitude, nil)
            locationPermissionAlert()
            debugPrint("Location service is not enabled")
        }
    }

    func locationPermissionCheckOnAppMode() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                debugPrint("Location service is enabled")
                self.updatingLocWithCompletionHandler?(.allowed, latitude, longitude, nil)
            case .denied, .restricted:
                debugPrint("Location service is denied/restricted")
                self.updatingLocWithCompletionHandler?(.denied, latitude, longitude, nil)
            case .notDetermined:
                debugPrint("Location service is not Determined")
                self.updatingLocWithCompletionHandler?(.waiting, latitude, longitude, nil)
            @unknown default:
                debugPrint("Scope for any new case in future")
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

        let alert = UIAlertController(title: "Allow Location Access", message: "Location access is required in order to accept payments. Turn on Location Services in your device settings.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            Utility.openSettigsApp()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in

        }

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let topVC = appDelegate.window?.topViewController() else {
            return
        }
        if topVC.isKind(of: UIViewController.self) {
            topVC.present(alert, animated: true, completion: nil)
        } else if topVC.isKind(of: SwipeNavigationController.self) {
            if let navVC = topVC as? SwipeNavigationController {
                if let topController = navVC.viewControllers.last {
                    topController.present(alert, animated: true, completion: nil)
                }
            }
        }

    }
}

// MARK: - Location Manager Delegate
extension LocationHelper: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(location.latitude) \(location.longitude)")
        latitude = location.latitude
        longitude = location.longitude
        self.getAddress()
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
    func getAddress() {
        if latitude == 0.0 && longitude == 0.0 {
            return
        }

        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location) { (placemarks, _) in
            guard let arrPlacemarks = placemarks, let place = arrPlacemarks.first else {
                self.address = Address()
                self.address.latitude = location.coordinate.latitude
                self.address.longitude = location.coordinate.longitude
                return
            }
            self.address = Address(with: place)
        }
    }

    func getLatLongFromAddress(_ address: String, completion : @escaping (CLLocationCoordinate2D?) -> Void) {
        //        let address = "1 Infinite Loop, Cupertino, CA 95014"

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
