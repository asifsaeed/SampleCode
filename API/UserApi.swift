//
//  UserApi.swift
//  Reperio
//
//  Created by Asif Saeed on 6/19/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import Firebase

class UserApi {
  
  var usersRef = Firestore.firestore().collection("users")
  
  func observeUser(withId uid: String, completion: @escaping (User) -> Void) {
    let docRef = usersRef.document(uid)
    docRef.getDocument { (document, error) in
      if let document = document, document.exists {
        let data = document.data()
        let user = User.transformUser(dict: data!, uid: document.documentID)
        print("Document: \(user)")
        completion(user)
      } else {
        print("Document does not exist")
      }
    }
  }
  
  func observeCurrentUser(completion: @escaping (User) -> Void) {
    guard let currentUser = Auth.auth().currentUser else {
      return
    }
    let docRef = usersRef.document(currentUser.uid)
    docRef.getDocument { (document, error) in
      if let document = document, document.exists {
        let data = document.data()
        let user = User.transformUser(dict: data!, uid: document.documentID)
        print("Document data: \(user)")
        completion(user)
      } else {
        let user = User()
        completion(user)
        print("Document does not exist")
      }
    }
  }
  
  func observeUsers(completion: @escaping (User) -> Void) {
    usersRef.getDocuments() { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        for document in querySnapshot!.documents {
          let data = document.data()
          let user = User.transformUser(dict: data, uid: document.documentID)
          completion(user)
        }
      }
    }
  }
  
  func observeUsers2(completion: @escaping ([User]) -> Void) {
    var users: [User] = []
    let myGroup = DispatchGroup()
    usersRef.getDocuments() { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        for document in querySnapshot!.documents {
          myGroup.enter()
          let data = document.data()
          let user = User.transformUser(dict: data, uid: document.documentID)
          users.append(user)
          myGroup.leave()
        }
        myGroup.notify(queue: .main){
           completion(users)
        }
      }
    }
  }

  func queryUsers(withText text: String, completion: @escaping (User) -> Void) {
    usersRef.getDocuments() { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        for document in querySnapshot!.documents {
          let data = document.data()
          let user = User.transformUser(dict: data, uid: document.documentID)
          if (user.name?.lowercased().contains(text.lowercased()))! {
            print("USER SEARCHED: \(user.name!)")
            completion(user)
          }
        }
      }
    }
  }
  
  func reduceSavedDeals(dealId: String, onSucess: @escaping (User) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
    let currentUser = Auth.auth().currentUser
    let docRef = usersRef.document((currentUser?.uid)!)
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
      let userDocument: DocumentSnapshot
      do {
        try userDocument = transaction.getDocument(docRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      guard let oldData = userDocument.data() as [String : AnyObject]? else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(userDocument)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      var newData = oldData
      var savedDeals: Dictionary<String, Bool>
      savedDeals = oldData["savedDeals"] as? [String : Bool] ?? [:]
      if let _ = savedDeals[dealId] {
        savedDeals.removeValue(forKey: dealId)
      } else {
        
      }
      
      newData["savedDeals"] = savedDeals as AnyObject?
      
      transaction.updateData(["savedDeals": savedDeals], forDocument: docRef)
      
      let transformedUser = User.transformUser(dict: newData, uid: (currentUser?.uid)!)
      onSucess(transformedUser)
      return nil
    }) { (object, error) in
      if let error = error {
        print("Transaction failed: \(error)")
        onError("Transaction failed: \(error)")
      } else {
        print("Transaction successfully committed!")
      }
    }
    
  }
  
  func incrementSavedDeals(dealId: String, onSucess: @escaping (User) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
    let currentUser = Auth.auth().currentUser
    let docRef = usersRef.document((currentUser?.uid)!)
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
      let userDocument: DocumentSnapshot
      do {
        try userDocument = transaction.getDocument(docRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      guard let oldData = userDocument.data() as [String : AnyObject]? else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(userDocument)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      var newData = oldData
      var savedDeals: Dictionary<String, Bool>
      savedDeals = oldData["savedDeals"] as? [String : Bool] ?? [:]
      if let _ = savedDeals[dealId] {
        
      } else {
        savedDeals[dealId] = true
      }
      
      newData["savedDeals"] = savedDeals as AnyObject?
      
      transaction.updateData(["savedDeals": savedDeals], forDocument: docRef)
      
      let transformedUser = User.transformUser(dict: newData, uid: (currentUser?.uid)!)
      onSucess(transformedUser)
      return nil
    }) { (object, error) in
      if let error = error {
        print("Transaction failed: \(error)")
        onError("Transaction failed: \(error)")
      } else {
        print("Transaction successfully committed!")
      }
    }
    
  }
  
  func incrementRedeemedDeals(dealId: String, dealPoints: Int, onSucess: @escaping (User) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
    let currentUser = Auth.auth().currentUser
    let docRef = usersRef.document((currentUser?.uid)!)
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
      let userDocument: DocumentSnapshot
      do {
        try userDocument = transaction.getDocument(docRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      guard let oldData = userDocument.data() as [String : AnyObject]? else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(userDocument)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      var newData = oldData
      var redeemedDeals: Dictionary<String, Bool>
      redeemedDeals = oldData["redeemedDeals"] as? [String : Bool] ?? [:]
      var points = oldData["points"] as? Int ?? 0
      if let _ = redeemedDeals[dealId] {
        
      } else {
        redeemedDeals[dealId] = true
        points += dealPoints
      }
      
      newData["redeemedDeals"] = redeemedDeals as AnyObject?
      newData["points"] = points as AnyObject?

      transaction.updateData(["points": points, "redeemedDeals": redeemedDeals], forDocument: docRef)
      
      let transformedUser = User.transformUser(dict: newData, uid: (currentUser?.uid)!)
      onSucess(transformedUser)
      return nil
    }) { (object, error) in
      if let error = error {
        print("Transaction failed: \(error)")
        onError("Transaction failed: \(error)")
      } else {
        print("Transaction successfully committed!")
      }
    }
    
  }
  
  
//
//  var CURRENT_USER: FIRUser? {
//    if let currentUser = FIRAuth.auth()?.currentUser {
//      return currentUser
//    }
//    
//    return nil
//  }
//  
//  var REF_CURRENT_USER: FIRDatabaseReference? {
//    guard let currentUser = FIRAuth.auth()?.currentUser else {
//      return nil
//    }
//    
//    return REF_USERS.child(currentUser.uid)
//  }
}
