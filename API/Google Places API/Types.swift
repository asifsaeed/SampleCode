//
//  Types.swift
//  GooglePlaces
//
//  Created by Asif Saeed on 4/17/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation

public extension GooglePlaces {
    public enum PlaceType: String {        
        case geocode = "geocode"
        case address = "address"
        case establishment = "establishment"
        case regions = "(regions)"
        case cities = "(cities)"
    }
}
