//
//  Location.swift
//  Reperio
//
//  Created by Asif Saeed on 4/27/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation


struct Location {
  let latitude: Double
  let longitude : Double
}

extension Location {
  init?(json:[String:Any]) {
    guard let lat = json["location"] as? [String:Any], let lng = json["location"] as? [String:Any] else { return nil }
    
    self.latitude = lat["lat"] as! Double
    self.longitude = lng["lng"] as! Double
  }
}
