//
//  User.swift
//  Reperio
//
//  Created by Asif Saeed on 4/26/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation

class User {
  
  // PROPERTIES:
  
  var email: String?
  var likes: Int?
  var latitude: NSNumber?
  var location: String?
  var longitude: NSNumber?
  var name: String?
  var preferences: [String]?
  var profilePicURL: String?
  var uid: String? = nil
  var points: Int?
  var isFollowing: Bool?
  var followCount: Int?
  var redeemedDeals: Dictionary<String, Any>?
  var savedDeals: Dictionary<String, Any>?
  
}

extension User {
  static func transformUser(dict: [String: Any], uid: String) -> User {
    let user = User()
    user.email = dict["email"] as? String
    user.likes = dict["likes"] as? Int
    user.latitude = dict["latitude"] as? NSNumber
    user.location = dict["location"] as? String
    user.longitude = dict["longitude"] as? NSNumber
    user.name = dict["name"] as? String
    user.preferences = dict["preferences"] as? [String]
    user.profilePicURL = dict["profilePicLink"] as? String
    user.followCount = dict["followCount"] as? Int ?? 0
    user.uid = uid
    user.redeemedDeals = dict["redeemedDeals"] as? Dictionary<String, Any>
    user.savedDeals = dict["savedDeals"] as? Dictionary<String, Any>
    return user
  }
}
