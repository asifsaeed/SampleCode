//
//  Post.swift
//  Reperio
//
//  Created by Asif Saeed on 5/31/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import Firebase

class Post {
  
  // PROPERTIES:
  
  var postID: String?
  var restaurantID: String?
  var userID: String?
  var caption: String?
  var timeStamp: Int?
  var likeCount: Int?
  var likes: Dictionary<String, Any>?
  var flags: Dictionary<String, Any>?
  var isLiked: Bool? = false
  var ratio: CGFloat?
  var photoURL: String?
  var videoURL: String?
  var restName: String?
  var restCity: String?
  
  
}

extension Post {
  static func transformPost(dict: [String: Any], id: String) -> Post {
    let post = Post()
    post.postID = id
    post.restaurantID = dict["restaurantID"] as? String
    post.caption = dict["caption"] as? String
    post.photoURL = dict["photoUrl"] as? String
    post.videoURL = dict["videoUrl"] as? String
    post.userID = dict["uid"] as? String
    post.likeCount = dict["likeCount"] as? Int
    post.likes = dict["likes"] as? Dictionary<String, Any>
    post.flags = dict["flags"] as? Dictionary<String, Any>

    post.ratio = dict["ratio"] as? CGFloat
    post.timeStamp = dict["timestamp"] as? Int
    post.restName = dict["restName"] as? String
    post.restCity = dict["restCity"] as? String
    
    if let currentUserId = Auth.auth().currentUser?.uid {
      if post.likes != nil {
        post.isLiked = post.likes![currentUserId] != nil
      }
    }
    
    return post
  }
  
  static func transformPostVideo() {
    
  }
}


