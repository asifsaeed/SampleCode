//
//  Restaurant.swift
//  Reperio
//
//  Created by Asif Saeed on 4/27/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MapKit


class Restaurant {
  
  //Properties
  
  var placeID : String?
  var name : String?
  var address : String? = ""
  var phoneNumber : String? = ""
  var distance : String? = ""
  var distanceSpec : Double? = 0.0
  var openNow : String? = "Hours May Vary"
  var rating : Double? = 0.0
  var priceLevel : String? = ""
  var defaultPhoto : URL? = URL(string: "https://firebasestorage.googleapis.com/v0/b/reperio-fbf71.appspot.com/o/WalkPicture1%403x%20copy.png?alt=media&token=a5c98737-6fe1-4ba2-8db7-df3997934262")
  var hoursOfOperation : String? = "Hours May Vary"
  var website : String? = ""
  var types: [String] = []
  var postCount : Int? = 0
  var friendPostCount : Int? = 0
  var cuisines: String? = ""
}

extension Restaurant {
  
  //Transform Functions

  func transform(fromGoogle restaurantData: GooglePlaces.PlaceDetailsResponse?, currentLocation: CLLocation, completion: @escaping (Restaurant) -> Void) {
    let rest = Restaurant()
    rest.placeID = restaurantData?.result?.placeID
    rest.name = restaurantData?.result?.name
    if let restAddress = restaurantData?.result?.formattedAddress {
      rest.address = restAddress
    }
    if let restPhoneNumber = restaurantData?.result?.formattedPhoneNumber {
      rest.phoneNumber = restPhoneNumber
      print("REST PHONE:" + restPhoneNumber)
    }
    if let restLocation = restaurantData?.result?.geometryLocation {
      let pointLocation = CLLocation(latitude: CLLocationDegrees(restLocation.latitude), longitude: CLLocationDegrees(restLocation.longitude))
      let distance = currentLocation.distance(from: pointLocation)
      print("RESTAURANT DISTANCE: \(distance)")
      rest.distanceSpec = distance
      let formatter = MKDistanceFormatter()
      formatter.unitStyle = .default
      formatter.units = .imperial
      let distanceInMiles = formatter.string(fromDistance: distance)
      rest.distance = distanceInMiles
    }
    if let restOpenNow = restaurantData?.result?.openingHours?.openNow {
      if restOpenNow {
        rest.openNow = "Open Now"
      } else {
        rest.openNow = "Closed"
      }
    }
    if let restRating = restaurantData?.result?.rating {
      rest.rating = restRating
    }
    if let restPriceLevel = restaurantData?.result?.priceLevel {
       rest.priceLevel = priceLevelDollarSigns(priceLevel: restPriceLevel)
    }
    if let photos = restaurantData?.result?.photos {
      if photos.count > 0 {
        let photoObject = photos[0]
        let photoRef = photoObject.photoReference
        let photoUrlString = GooglePlaces.urlForPhoto(reference: photoRef!)
        rest.defaultPhoto = URL(string: photoUrlString)
        print("DEFAULT PHOTO URL: \(photoUrlString)")
      }
    }
    if let restHours = restaurantData?.result?.openingHours?.weekdayText {
      let dayInt = getDayOfWeek()
      let hoursHours = restHours[dayInt - 1]
      let stringComponents = hoursHours.components(separatedBy: ": ")
      let hours = stringComponents.last
      rest.hoursOfOperation = hours
      print("restaurant hours: \(hours!)")
    }
    if let restWebsite = restaurantData?.result?.website{
      rest.website = restWebsite
    }
    if let restType = restaurantData?.result?.types{
      rest.types = restType
      print("RESTAURANT TYPES: \(restType)")
      
    }
    
    completion(rest)
  }
  
  func priceLevelDollarSigns(priceLevel: Int?) -> String {
    switch priceLevel {
    case 0:
      return ""
    case 1:
      return "• $"
    case 2:
      return "• $$"
    case 3:
      return "• $$$"
    case 4:
      return "• $$$$"
    default:
      return ""
    }
    
  }
  func getDayOfWeek() -> Int {
    let today = Date()
    let formatter  = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: today)
    print("Weekday: \(weekDay)")
    return weekDay
    
  }
  
}
