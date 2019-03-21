//
//  PlaceNearbySearchResponse.swift
//  Reperio
//
//  Created by Asif Saeed on 5/3/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK: - PlaceNearbySearchResponse
public extension GooglePlaces {
  public struct PlaceNearbySearchResponse: Mappable {
    public var status: StatusCode?
    public var errorMessage: String?
    
    public var results: [Result] = []
    public var htmlAttributions: [String] = []
    
    public init() {}
    public init?(map: Map) { }
    
    public mutating func mapping(map: Map) {
      status <- (map["status"], EnumTransform())
      errorMessage <- map["error_message"]
      
      results <- map["results"]
      htmlAttributions <- map["html_attributions"]
    }
    
    /**
     *  Result
     */
    public struct Result: Mappable {
      
      /// A textual identifier that uniquely identifies a place. To retrieve information about the place, pass this identifier in the placeId field of a Places API request. For more information about place IDs, see the place ID overview.
      public var placeID: String!
 
      public init() {}
      public init?(map: Map) { }
      
      public mutating func mapping(map: Map) {
        placeID <- map["place_id"]
      }
    }
  }
}
