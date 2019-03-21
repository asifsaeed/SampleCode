//
//  PostApi.swift
//  Reperio
//
//  Created by Asif Saeed on 6/19/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import Firebase

class PostApi {
  
  var postsRef = Firestore.firestore().collection("posts")
  
  func observePosts(completion: @escaping (Post) -> Void) {
    postsRef.getDocuments() { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        for document in querySnapshot!.documents {
          let data = document.data()
          let post = Post.transformPost(dict: data, id: document.documentID)
          completion(post)
        }
      }
    }
  }
  
  func observePost(withId id: String, completion: @escaping (Post) -> Void) {
    let docRef = postsRef.document(id)
    docRef.getDocument { (document, error) in
      if let document = document, document.exists {
        let data = document.data()
        let post = Post.transformPost(dict: data!, id: document.documentID)
        print("Post: \(post)")
        completion(post)
      } else {
        print("Post does not exist")
      }
    }
  }
  
  func observePostCount(withId id: String, completion: @escaping (Int) -> Void) {
    let userPostsRef = postsRef.whereField("uid", isEqualTo: id)
    
    userPostsRef.getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
        if querySnapshot == nil {
          print("is empty????")
          completion(0)
        }
      } else {
        if (querySnapshot?.isEmpty)! {
          completion(0)
        } else {
          let count = querySnapshot?.count
          completion(count!)
        }
      }
    }
  }
  
  func observeOwnPostCount(completion: @escaping (Int) -> Void) {
    let uid = Auth.auth().currentUser?.uid
    let userPostsRef = postsRef.whereField("uid", isEqualTo: String(uid!))
    
    userPostsRef.getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
        if querySnapshot == nil {
          print("is empty????")
          completion(0)
        }
      } else {
        if (querySnapshot?.isEmpty)! {
          completion(0)
        } else {
          let count = querySnapshot?.count
          completion(count!)
        }
      }
    }
  }
  
  func observeUserLikesCount(withId id: String, completion: @escaping (Int) -> Void) {
    let userPostsRef = postsRef.whereField("uid", isEqualTo: id)
    
    userPostsRef.getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
        if querySnapshot == nil {
          print("is empty????")
          completion(0)
        }
      } else {
        if (querySnapshot?.isEmpty)! {
          completion(0)
        } else {
          var likes = 0
          for doc in (querySnapshot?.documents)! {
            let docCount = doc["likeCount"] as? Int ?? 0
            likes += docCount
            completion(likes)
          }
        }
      }
    }
  }
  
  func observeOwnLikesCount(completion: @escaping (Int) -> Void) {
    let uid = Auth.auth().currentUser?.uid
    let userPostsRef = postsRef.whereField("uid", isEqualTo: String(uid!))
    
    userPostsRef.getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
        if querySnapshot == nil {
          print("is empty????")
          completion(0)
        }
      } else {
        if (querySnapshot?.isEmpty)! {
          completion(0)
        } else {
          var likes = 0
          for doc in (querySnapshot?.documents)! {
            let docCount = doc["likeCount"] as? Int ?? 0
            print("LIKE COUNT \(docCount)")
            likes += docCount
            completion(likes)
          }
        }
      }
    }
  }
  
  func observeLikeCount(withPostId id: String, completion: @escaping (Int) -> Void) {
    let docRef = postsRef.document(id)
    docRef.addSnapshotListener { documentSnapshot, error in
      guard let document = documentSnapshot else {
        print("Error fetching document: \(error!)")
        return
      }
      print("Current data: \(document.data())")
      let data = document.data()
      let post = Post.transformPost(dict: data!, id: document.documentID)
      completion(post.likeCount!)
    }
    
  }
  
  func removeObserveLikeCount(id: String, likeHandler: UInt) {
    let docRef = postsRef.document(id)
    let listener = docRef.addSnapshotListener { querySnapshot, error in }
    listener.remove()
  }
  
  
  func incrementLikes(postId: String, onSucess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
    let docRef = postsRef.document(postId)
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
      let postDocument: DocumentSnapshot
      do {
        try postDocument = transaction.getDocument(docRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      guard let oldData = postDocument.data() as [String : AnyObject]?, let uid = Auth.auth().currentUser?.uid else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(postDocument)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      var newPost = oldData
      var likes: Dictionary<String, Bool>
      likes = oldData["likes"] as? [String : Bool] ?? [:]
      var likeCount = oldData["likeCount"] as? Int ?? 0
      if let _ = likes[uid] {
        likeCount -= 1
        likes.removeValue(forKey: uid)
      } else {
        likeCount += 1
        likes[uid] = true
      }
      
      newPost["likeCount"] = likeCount as AnyObject?
      newPost["likes"] = likes as AnyObject?
      
      transaction.updateData(["likes": likes, "likeCount": likeCount], forDocument: docRef)
      
      let transformedPost = Post.transformPost(dict: newPost, id: postId)
      onSucess(transformedPost)
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
  
  func incrementFlags(postId: String, onSucess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
    let docRef = postsRef.document(postId)
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
      let postDocument: DocumentSnapshot
      do {
        try postDocument = transaction.getDocument(docRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }
      
      guard let oldData = postDocument.data() as [String : AnyObject]?, let uid = Auth.auth().currentUser?.uid else {
        let error = NSError(
          domain: "AppErrorDomain",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(postDocument)"
          ]
        )
        errorPointer?.pointee = error
        return nil
      }
      
      var newPost = oldData
      var flags: Dictionary<String, Bool>
      flags = oldData["flags"] as? [String : Bool] ?? [:]
      var flagCount = oldData["flagCount"] as? Int ?? 0
      if let _ = flags[uid] {

      } else {
        flagCount += 1
        flags[uid] = true
      }
      
      newPost["flagCount"] = flagCount as AnyObject?
      newPost["flags"] = flags as AnyObject?
      
      transaction.updateData(["flags": flags, "flagCount": flagCount], forDocument: docRef)
      
      let transformedPost = Post.transformPost(dict: newPost, id: postId)
      onSucess(transformedPost)
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


