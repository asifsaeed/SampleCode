//
//  HelperService.swift
//  Reperio
//
//  Created by Asif Saeed on 6/20/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import Firebase

class HelperService {
  
  static func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, restaurantId: String, restName: String, restCity: String, caption: String, onSuccess: @escaping () -> Void) {
    if let videoUrl = videoUrl {
      self.uploadVideoToFirebaseStorage(videoUrl: videoUrl, onSuccess: { (videoUrl) in
        uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
          sendDataToDatabase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, ratio: ratio, restaurantId: restaurantId, restName: restName, restCity: restCity, caption: caption, onSuccess: onSuccess)
        })
      })
      //self.senddatatodatabase
    } else {
      uploadImageToFirebaseStorage(data: data) { (photoUrl) in
        self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, restaurantId: restaurantId, restName: restName, restCity: restCity, caption: caption, onSuccess: onSuccess)
      }
    }
  }
  
  static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void) {
    let videoIdString = NSUUID().uuidString
    let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("posts").child(videoIdString)
    storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
      if error != nil {
//        ProgressHUD.showError(error!.localizedDescription)
        return
      }
      if let videoUrl = metadata?.downloadURL()?.absoluteString {
        onSuccess(videoUrl)
      }
    }
  }
  
  static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
    let photoIdString = NSUUID().uuidString
    let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("posts").child(photoIdString)
    storageRef.putData(data, metadata: nil) { (metadata, error) in
      if error != nil {
//        ProgressHUD.showError(error!.localizedDescription)
        return
      }
      if let photoUrl = metadata?.downloadURL()?.absoluteString {
        onSuccess(photoUrl)
      }
      
    }
  }
  
  static func sendDataToDatabase(photoUrl: String, videoUrl: String? = nil, ratio: CGFloat, restaurantId: String, restName: String, restCity: String, caption: String, onSuccess: @escaping () -> Void) {
    
    guard let currentUser = Auth.auth().currentUser else {
      return
    }
    
    let currentUserId = currentUser.uid
    
    let timestamp = Int(Date().timeIntervalSince1970)
    
    var dict = ["uid": currentUserId ,"photoUrl": photoUrl, "caption": caption, "likeCount": 0, "ratio": ratio, "restaurantID": restaurantId, "restName": restName, "restCity": restCity, "timestamp": timestamp] as [String : Any]
    if let videoUrl = videoUrl {
      dict["videoUrl"] = videoUrl
    }
    
    var ref: DocumentReference? = nil
    ref = Api.Post.postsRef.addDocument(data: dict) { err in
      if let err = err {
        print("Error adding document: \(err)")
      } else {
        print("Document added with ID: \(ref!.documentID)")
        onSuccess()
      }
    }
  }
  
  static func deleteMedia(mediaUID: String, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
//    let storageRef = Storage.storage().reference().child("posts").child(mediaUID)
//    storageRef.delete { error in
      // Storage File deleted successfully
    Firestore.firestore().collection("posts").document(mediaUID).delete() { err in
      if let err = err {
        print("Error removing document: \(err)")
        onError()
      } else {
        print("Document successfully removed!")
        onSuccess()
      }
    }
//    }
  }
  
}
