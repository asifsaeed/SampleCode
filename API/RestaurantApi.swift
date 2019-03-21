//
//  RestaurantApi.swift
//  Reperio
//
//  Created by Asif Saeed on 7/4/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import Alamofire

class RestaurantApi {
  
  var restaurantsRef = Firestore.firestore().collection("restaurants")
  
  func observeUser(withId uid: String) {
//    let docRef = usersRef.document(uid)
//    docRef.getDocument { (document, error) in
//      if let document = document, document.exists {
//        let data = document.data()
//        let user = User.transformUser(dict: data!, uid: document.documentID)
//        print("Document: \(user)")
//        completion(user)
//      } else {
//        print("Document does not exist")
//      }
//    }
  }
  
  func fetchAndTransformRestaurantsFromFollowing(restaurantIds: [String], locationInfo: CLLocation, completion: @escaping ([Restaurant]) -> Void) {
    var restaurants: [Restaurant] = []
    let myGroup = DispatchGroup()
    for restaurantId in restaurantIds {
      myGroup.enter()
      DispatchQueue.main.async {
        GoogleMapsService.provide(apiKey: "AIzaSyAwczS8LFjHVqNRFzAlXmuaGkHy3HmVz1M")
        GooglePlaces.placeDetails(forPlaceID: restaurantId, extensions: nil, language: nil, completion: { (rest, err) in
          let restInit = Restaurant()
          if rest?.result != nil {
            if !((rest?.result?.photos.isEmpty)!) && (rest?.result?.rating != nil) {
              restInit.transform(fromGoogle: rest, currentLocation: locationInfo) { (restInfo) in
                restaurants.append(restInfo)
                myGroup.leave()
              }
            }
          }
        })
      }
    }
    myGroup.notify(queue: .main){
      print("RESTAURANT IDS: \(restaurants.count)")
      completion(restaurants)
    }
  }
  
  func observeRestaurantPostsFromFollowing(userIds: [String], completion: @escaping ([String]) -> Void) {
    var restaurantIds: [String] = []
    let myGroup = DispatchGroup()
    for user in userIds {
      myGroup.enter()
      let userPostsRef = Api.Post.postsRef.whereField("uid", isEqualTo: user)
      let myGroup2 = DispatchGroup()
      userPostsRef.getDocuments { (querySnapshot, err) in
        if let err = err {
          print("Error getting documents: \(err)")
          if querySnapshot == nil {
          }
        } else {
          if !(querySnapshot?.isEmpty)! {
            
            for document in querySnapshot!.documents {
              myGroup2.enter()
              let restaurantId = document.data()["restaurantID"] as? String
              restaurantIds.append(restaurantId!)
              myGroup2.leave()
            }
           
          }
          myGroup2.notify(queue: .main){
            myGroup.leave()
          }
        }
      }
    }
    myGroup.notify(queue: .main){
      print("RESTAURANT IDS: \(restaurantIds.count)")
      completion(restaurantIds)
    }
  }
  
  func observePostCountFromFriends(withId id: String, userIds: [String], completion: @escaping (Int) -> Void) {
    var postCountFromFriends = 0
    for user in userIds {
      
      let userPostsRef = Api.Post.postsRef.whereField("restaurantID", isEqualTo: id).whereField("uid", isEqualTo: user)
      
      userPostsRef.getDocuments { (querySnapshot, err) in
        if let err = err {
          print("Error getting documents: \(err)")
          if querySnapshot == nil {
          }
        } else {
          if (querySnapshot?.isEmpty)! {
          } else {
            let count = querySnapshot?.count
            postCountFromFriends += count!
            completion(postCountFromFriends)
          }
        }
      }
    }
  }
  
  func observeRestaurantPostsCount(withId id: String, completion: @escaping (Int) -> Void) {
    let userPostsRef = Api.Post.postsRef.whereField("restaurantID", isEqualTo: id)
    
    userPostsRef.getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
        if querySnapshot == nil {
          print("is empty????")
          completion(0)
        }
      } else {
        if (querySnapshot?.isEmpty)! {
          print("is empty")
          completion(0)
        } else {
          let count = querySnapshot?.count
          print("REST POST COUNT: \(count)")
          completion(count!)
        }
      }
    }
  }

}
