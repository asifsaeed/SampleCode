//
//  LocationCoordinate2DTransform.swift
//  GoogleMapsDirections
//
//  Created by Asif Saeed on 4/17/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import ObjectMapper

class LocationCoordinate2DTransform: TransformType {
    typealias LocationCoordinate2D = GoogleMapsService.LocationCoordinate2D
    typealias Object = LocationCoordinate2D
    typealias JSON = [String : Any]
    
    func transformFromJSON(_ value: Any?) -> Object? {
        if let value = value as? JSON {
            guard let latitude = value["lat"] as? Double, let longitude = value["lng"] as? Double else {
                NSLog("Error: lat/lng is not Double")
                return nil
            }
            
            return LocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        if let value = value {
            return [
                "lat" : "\(value.latitude)",
                "lng" : "\(value.longitude)"
            ]
        }
        return nil
    }
}
