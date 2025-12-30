//
//  LocationCell.swift
//  Solid
//
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var lblAddressTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblCountryTitle: UILabel!
    @IBOutlet weak var lblCountry: UILabel!

    @IBOutlet weak var mapView: MKMapView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mapView.delegate = self

		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        lblAddressTitle.font = titleFont
        lblAddressTitle.textColor = UIColor.secondaryColor
        lblAddressTitle.textAlignment = .left

        lblCountryTitle.font = titleFont
        lblCountryTitle.textColor = UIColor.secondaryColor
        lblCountryTitle.textAlignment = .left
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblAddress.font = labelFont
        lblAddress.textColor = UIColor.primaryColor
        lblAddress.textAlignment = .left

        lblCountry.font = labelFont
        lblCountry.textColor = UIColor.primaryColor
        lblCountry.textAlignment = .left

        mapView.cornerRadius = Constants.cornerRadiusThroughApp
        mapView.layer.masksToBounds = true
        
        self.backgroundColor = .background
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func showLocationData(forRow rowData: Address) {
		let location = rowData
        let addrString = location.addressString()
        setupMapfor(addrString)

        lblAddressTitle.text = Utility.localizedString(forKey: "address")
        lblCountryTitle.text = Utility.localizedString(forKey: "contact_country_title")

        lblAddress.text = addrString
        lblCountry.text = location.country
    }

    func setupMapfor(_ address: String) {
        LocationHelper.shared.getLatLongFromAddress(address, completion: { (coordinates) in
            if let coordi = coordinates {

               self.displayMapUsingLocationCoordinates(coordi)
            }
        })
    }

    func displayMapUsingLocationCoordinates(_ coordinates: CLLocationCoordinate2D) {
        // Takes a center point and a span in miles (converted from meters using above method)
        let region = self.mapView.regionThatFits(MKCoordinateRegion(center: coordinates, latitudinalMeters: 5000, longitudinalMeters: 5000))
        self.mapView.setRegion(region, animated: true)

        let circle = MKCircle(center: coordinates, radius: 1800)
        self.mapView.addOverlay(circle)
    }

    // FOR LOCATION..
    func showTransactionLocationData(forRow rowData: TransactionModel) {
		if let location = rowData.card?.merchant {
			var postLocation = Address()
			postLocation.state = location.merchantState
			postLocation.city = location.merchantCity
			postLocation.country = location.merchantCountry

            let addrString = postLocation.addressString()
            setupMapfor(addrString)

            lblAddressTitle.text = Utility.localizedString(forKey: "address")
            lblCountryTitle.text = Utility.localizedString(forKey: "contact_country_title")

            lblAddress.text = addrString
            lblCountry.text = location.merchantCountry
		}
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblAddressTitle.textColor = UIColor.secondaryColor
        lblCountryTitle.textColor = UIColor.secondaryColor
        lblAddress.textColor = UIColor.primaryColor
        lblCountry.textColor = UIColor.primaryColor
    }
}

extension LocationCell: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.brandDisableColor
        renderer.strokeColor = UIColor.primaryColor
        renderer.lineWidth = 1
        return renderer
    }
}
