//
//  ATMLocationsVC.swift
//  Solid
//
//  Created by Solid iOS Team on 17/12/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import SkeletonView
import UIKit
import MapKit

class ATMLocationsVC: BaseVC, UIActionSheetDelegate {
    
    var cardModel: CardModel?
    @IBOutlet weak var tblDetails: UITableView!
    @IBOutlet weak var lblNoATMTitle: UILabel!
    var atmLocation = [ATMLocationsAddress]()
    var totalCount = Int()
    var limit = 100
    var limitOffset = 0
    var radius = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setupInitialUI()
        
        self.activityIndicatorBegin()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.0) {
            self.getATMLocations()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        atmLocation.removeAll()
        super.viewWillAppear(animated)
    }
}

// MARK: - UI methods
extension ATMLocationsVC {
    
    func setupInitialUI() {
        registerCell()
        lblNoATMTitle.isHidden = true
        lblNoATMTitle.text = Utility.localizedString(forKey: "no_ATM")
        lblNoATMTitle.font = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblNoATMTitle.textAlignment = .center
        lblNoATMTitle.textColor = UIColor.secondaryColorWithOpacity
    }
        
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        addBackNavigationbarButton()
        self.title = Utility.localizedString(forKey: "ATM_list")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblNoATMTitle.textColor = UIColor.secondaryColorWithOpacity
    }
}

// MARK: - Tableview methdos
extension ATMLocationsVC: UITableViewDelegate, UITableViewDataSource {

    func registerCell() {
        tblDetails.estimatedRowHeight = 30
        tblDetails.rowHeight = UITableView.automaticDimension

        tblDetails.register(UINib(nibName: "ATMLocationCell", bundle: .main), forCellReuseIdentifier: "ATMLocationCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return atmLocation.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ATMLocationCell") as? ATMLocationCell {
            cell.configureCard(frontData: atmLocation[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAtmLocation = atmLocation[indexPath.row]

        let appleOption =  Utility.localizedString(forKey: "maptype_apple")
        let googleOption =  Utility.localizedString(forKey: "maptype_google")
        let googleMapsInstalled = UIApplication.shared.canOpenURL(URL(string: Constants.googleMapAppUrl)!)
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: selectedAtmLocation.name, preferredStyle: .actionSheet)

        let appleOptionAction: UIAlertAction = UIAlertAction(title: appleOption, style: .default) { _ -> Void in
            if let latitude = selectedAtmLocation.coordinates?.latitude, let longitude = selectedAtmLocation.coordinates?.longitude {
                let regionDistance: CLLocationDistance = 10
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = selectedAtmLocation.name
                mapItem.openInMaps(launchOptions: options)
            }
        }
        
        let googleOptionAction: UIAlertAction = UIAlertAction(title: googleOption, style: .default) { _ -> Void in
                if let latitude = selectedAtmLocation.coordinates?.latitude, let longitude = selectedAtmLocation.coordinates?.longitude {
                    let  urlString = "?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=loc:\(latitude),\(longitude)"
                    let mapString = googleMapsInstalled ? Constants.googleMapAppUrl : "https:\(Constants.googleMapUrl)"
                    UIApplication.shared.open(URL(string: "\(mapString)\(urlString)")!, options: [:], completionHandler: nil)
                }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(appleOptionAction)
        actionSheetController.addAction(googleOptionAction)
        actionSheetController.addAction(cancelAction)
        
        if Utility.isDeviceIpad(), let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
                popoverController.permittedArrowDirections = []
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

//API Manages
extension ATMLocationsVC {
    
    func getATMLocations() {
        
        if let aCardModel = self.cardModel, let cardId = aCardModel.id {
            
            if self.atmLocation.count != 0 && self.atmLocation.count >= totalCount {
                return
            }
            
            let latitude = LocationHelper.shared.latitude
            let longitude = LocationHelper.shared.longitude
            
            CardViewModel.shared.getATMlocation(cardId: cardId, limit: "\(limit)", offset: "\(limitOffset)", latitude: "\(latitude)", longitude: "\(longitude)", radius: "\(radius)") { (response, errorMessage) in
                self.activityIndicatorEnd()
                
                if let error = errorMessage {
                    self.lblNoATMTitle.isHidden = false
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    print("")
                    self.totalCount = response?.total ?? 0
                    self.atmLocation.removeAll()
                    if let address = response?.data {
                        self.atmLocation += address
                        self.tblDetails.reloadData()
                    }
                    
                    if self.atmLocation.count == 0 {
                        self.lblNoATMTitle.isHidden = false
                    }
                }
            }
        }
    }
}
