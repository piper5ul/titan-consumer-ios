//
//  AppConfigurations.swift
//  Solid
//
//  Created by Solid iOS Team on 11/02/21.
//

import Foundation
import GooglePlaces
import Segment

struct AppConfigurations {
    static let enableJailBreakDetection     = true
    static func addAllAppConfigurations() {
        configureGooglePlaces()
    }
    
    static func configureGooglePlaces() {
        GMSPlacesClient.provideAPIKey(Config.GooglePlaces.apiKey)
    }
    
    static func configureSegment() {
        guard let segmentAPIKey = AppMetaDataHelper.shared.currentEnvKeys.segmentKey else { return  }
        
		let configuration = AnalyticsConfiguration(writeKey: segmentAPIKey)
        
        configuration.recordScreenViews = false
        
        //LIFE CYCLE EVENTS...
        configuration.trackApplicationLifecycleEvents = true
        
		Segment.sharedSegment.segmentConfigObj = Analytics(configuration: configuration)
    }
}
