//
//  FollowApi.swift
//  Reperio
//
//  Created by Asif Saeed on 6/19/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import Firebase

class FollowApi {
  
  var followingRef = Firestore.firestore().collection("users")
  
  func followAction(withUser id: String) {
    let currentUser = Auth.auth().currentUser?.uid
    let docRef = followingRef.document(currentUser!)
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
      let followingDocument: DocumentSnapshot
      do {
        try followingDocument = transaction.getDocument(docRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      guard let oldData = followingDocument.data() as [String : AnyObject]? else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(followingDocument)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      var following: Dictionary<String, Bool>
      following = oldData["following"] as? [String : Bool] ?? [:]
      var followCount = oldData["followCount"] as? Int ?? 0
      if let _ = following[id] {
        followCount -= 1
        following.removeValue(forKey: id)
      } else {
        followCount += 1
        following[id] = true
      }
      
      transaction.updateData(["following": following, "followCount": followCount], forDocument: docRef)
      
      return nil
    }) { (object, error) in
      if let error = error {
        print("Transaction failed: \(error)")
      } else {
        print("Transaction successfully committed!")
      }
    }
    
  }
  
  func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
    let currentUser = Auth.auth().currentUser?.uid
    followingRef.document(currentUser!).getDocument { (document, error) in
      if let document = document, document.exists {
        guard let userDoc = document.data() as [String : AnyObject]? else {
          return
        }
        var following: Dictionary<String, Bool>
        following = userDoc["following"] as? [String : Bool] ?? [:]
        if let _ = following[userId] {
          completed(true)
        } else {
          completed(false)
        }
      } else {
        completed(false)
        print("Document does not exist")
      }
    }
  }
  
  
  
  func fetchCountFollowing(completion: @escaping (Int) -> Void) {
    let currentUser = Auth.auth().currentUser?.uid
    followingRef.document(currentUser!).getDocument { (document, error) in
      if let document = document, document.exists {
        let followingUsers = document.data()
        if (followingUsers?.isEmpty)! {
          completion(0)
        } else {
          var followCount = 0
          for user in followingUsers! {
            if let _ = user.value as? Bool {
              followCount += 1
              completion(followCount)
            }
          }
        }
      } else {
        completion(0)
        print("Document does not exist")
      }
    }
  }
  
}
