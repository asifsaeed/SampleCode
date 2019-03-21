//
//  Deals.swift
//  Reperio
//
//  Created by Asif Saeed on 6/19/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import Foundation
import Firebase

class Deal {
  
  // PROPERTIES:
  
  var dealID: String?
  var restaurantID: String?
  var redeemCount: Int?
  var points: Int?
  var name: String?
  var imageUrl: String?
  var active: Bool?
  var details: String?
  var redeems: Dictionary<String, Any>?
}

extension Deal {
  
  static func transformDeal(dict: [String: Any], id: String) -> Deal {
    let deal = Deal()
    deal.dealID = id
    deal.restaurantID = dict["restaurantID"] as? String
    deal.imageUrl = dict["imageUrl"] as? String
    deal.active = dict["active"] as? Bool
    deal.points = dict["points"] as? Int
    deal.name = dict["name"] as? String
    deal.details = dict["details"] as? String
    deal.redeems = dict["redeems"] as? Dictionary<String, Any>
    return deal
  }
}

