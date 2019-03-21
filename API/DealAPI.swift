//
//  DealAPI.swift
//  Reperio
//
//  Created by Asif Saeed on 6/29/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import Firebase

class DealApi {
  
  var dealsRef = Firestore.firestore().collection("deals")
  
  func observeDeals(completion: @escaping (Deal) -> Void) {
    dealsRef.getDocuments() { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        for document in querySnapshot!.documents {
          let data = document.data()
          let deal = Deal.transformDeal(dict: data, id: document.documentID)
          completion(deal)
        }
      }
    }
  }
  
  func observeSavedDeals(completion: @escaping (Deal) -> Void) {
    Api.User.observeCurrentUser { (user) in
      let ids = user.savedDeals?.keys
      for id in ids! {
        let docRef = self.dealsRef.document(id)
        docRef.getDocument { (document, error) in
          if let document = document, document.exists {
            let data = document.data()
            let deal = Deal.transformDeal(dict: data!, id: id)
            print("Deal: \(deal)")
            completion(deal)
          } else {
            print("Post does not exist")
          }
        }
      }
    }
  }
    
  func observeRedeemedDeals(completion: @escaping (Deal) -> Void) {
    Api.User.observeCurrentUser { (user) in
      let ids = user.redeemedDeals?.keys
      if ids != nil {
        for id in (ids)! {
          let docRef = self.dealsRef.document(id)
          docRef.getDocument { (document, error) in
            if let document = document, document.exists {
              let data = document.data()
              let deal = Deal.transformDeal(dict: data!, id: id)
              print("Deal: \(deal)")
              completion(deal)
            } else {
              print("Post does not exist")
            }
          }
        }
      }
    }
  }
    
//    let docRef = usersRef.document(currentUser.uid)
//    docRef.getDocument { (document, error) in
//      if let document = document, document.exists {
//        let data = document.data()
//        let user = User.transformUser(dict: data!, uid: document.documentID)
//        print("Document data: \(user)")
//        completion(user)
//      } else {
//        print("Document does not exist")
//      }
//    }
  
  func incrementRedeemCount(dealId: String, onSucess: @escaping (Deal) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
    let docRef = dealsRef.document(dealId)
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
      let dealDocument: DocumentSnapshot
      do {
        try dealDocument = transaction.getDocument(docRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      guard let oldData = dealDocument.data() as [String : AnyObject]?, let uid = Auth.auth().currentUser?.uid else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(dealDocument)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      var newDeal = oldData
      var redeems: Dictionary<String, Bool>
      redeems = oldData["redeems"] as? [String : Bool] ?? [:]
      var redeemCount = oldData["redeemCount"] as? Int ?? 0
      if let _ = redeems[uid] {

      } else {
        redeemCount += 1
        redeems[uid] = true
      }
      
      newDeal["redeemCount"] = redeemCount as AnyObject?
      newDeal["redeems"] = redeems as AnyObject?
      
      transaction.updateData(["redeems": redeems, "redeemCount": redeemCount], forDocument: docRef)
      
      let transformedDeal = Deal.transformDeal(dict: newDeal, id: dealId)
      onSucess(transformedDeal)
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
  
}
