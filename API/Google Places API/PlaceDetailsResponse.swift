//
//  PlaceDetailsResponse.swift
//  GooglePlaces
//
//  Created by Asif Saeed on 4/17/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK: - PlaceAutocompleteResponse
public extension GooglePlaces {
    public struct PlaceDetailsResponse: Mappable {
        public var status: StatusCode?
        public var errorMessage: String?
        
        public var result: Result?
        public var htmlAttributions: [String] = []
        
        public init() {}
        public init?(map: Map) { }
        
        public mutating func mapping(map: Map) {
            status <- (map["status"], EnumTransform())
            errorMessage <- map["error_message"]
            
            result <- map["result"]
            htmlAttributions <- map["html_attributions"]
        }
        
        public struct Result: Mappable {
            /// an array of separate address components used to compose a given address. For example, the address "111 8th Avenue, New York, NY" contains separate address components for "111" (the street number, "8th Avenue" (the route), "New York" (the city) and "NY" (the US state).
//            public var addressComponents: [AddressComponent] = []
          
            /// a string containing the human-readable address of this place. Often this address is equivalent to the "postal address," which sometimes differs from country to country. This address is generally composed of one or more address_component fields.
            public var formattedAddress: String?
            
            /// the place's phone number in its local format. For example, the formatted_phone_number for Google's Sydney, Australia office is (02) 9374 4000.
            public var formattedPhoneNumber: String?
            
            /// geometry.location the geocoded latitude,longitude value for this place.
            public var geometryLocation: LocationCoordinate2D?
          
            /// the URL of a suggested icon which may be displayed to the user when indicating this result on a map
//            public var icon: URL?
          
            /// the human-readable name for the returned result. For establishment results, this is usually the canonicalized business name.
            public var name: String?
            
            /// Opening Hours
            public var openingHours: OpeningHours?
            
            /// a boolean flag indicating whether the place has permanently shut down (value true). If the place is not permanently closed, the flag is absent from the response.
            public var permanentlyClosed: Bool = false
            
            /// an array of photo objects, each containing a reference to an image. A Place Details request may return up to ten photos. More information about place photos and how you can use the images in your application can be found in the Place Photos documentation.
            public var photos: [Photo] = []
            
            /// A textual identifier that uniquely identifies a place. To retrieve information about the place, pass this identifier in the placeId field of a Places API request. For more information about place IDs, see the place ID overview.
            public var placeID: String?
            
            /// The price level of the place, on a scale of 0 to 4. The exact amount indicated by a specific value will vary from region to region.
            public var priceLevel: Int?
            
            /// the place's rating, from 1.0 to 5.0, based on aggregated user reviews.
            public var rating: Double?
          

            
            /// an array of feature types describing the given result. See the list of supported types for more information.
            public var types: [String] = []
            
            /// the number of minutes this place’s current timezone is offset from UTC. For example, for places in Sydney, Australia during daylight saving time this would be 660 (+11 hours from UTC), and for places in California outside of daylight saving time this would be -480 (-8 hours from UTC).
//            public var utcOffset: Int?
          
            /// a simplified address for the place, including the street name, street number, and locality, but not the province/state, postal code, or country. For example, Google's Sydney, Australia office has a vicinity value of 48 Pirrama Road, Pyrmont.
//            public var vicinity: String?
          
            /// the authoritative website for this place, such as a business' homepage.
            public var website: String?
            
            public init() {}
            public init?(map: Map) { }
            
            public mutating func mapping(map: Map) {
//                addressComponents <- map["address_components"]
                formattedAddress <- map["formatted_address"]
                formattedPhoneNumber <- map["formatted_phone_number"]
                geometryLocation <- (map["geometry.location"], LocationCoordinate2DTransform())
//                icon <- (map["icon"], URLTransform())
                name <- map["name"]
                openingHours <- map["opening_hours"]
                permanentlyClosed <- map["permanently_closed"]
                photos <- map["photos"]
                placeID <- map["place_id"]
                priceLevel <- map["price_level"]
                rating <- map["rating"]
                types <- map["types"]
//                utcOffset <- map["utc_offset"]
//                vicinity <- map["vicinity"]
                website <- map["website"]

              
            }
            
            /**
             *  AddressComponent
             address components used to compose a given address. For example, the address "111 8th Avenue, New York, NY" contains separate address components for "111" (the street number, "8th Avenue" (the route), "New York" (the city) and "NY" (the US state)
             */
            public struct AddressComponent: Mappable {
                /// an array indicating the type of the address component.
                public var types: [String] = []
                
                /// the full text description or name of the address component.
                public var longName: String?
                
                /// an abbreviated textual name for the address component, if available. For example, an address component for the state of Alaska may have a long_name of "Alaska" and a short_name of "AK" using the 2-letter postal abbreviation.
                public var shortName: String?
                
                public init() {}
                public init?(map: Map) { }
                
                public mutating func mapping(map: Map) {
                    types <- map["types"]
                    longName <- map["long_name"]
                    shortName <- map["short_name"]
                }
            }
            
            public struct OpeningHours: Mappable {
                /// a boolean value indicating if the place is open at the current time.
                public var openNow: Bool = false
                
                /// an array of opening periods covering seven days, starting from Sunday, in chronological order.
//                public var periods: [Period] = []
              
                /// an array of seven strings representing the formatted opening hours for each day of the week. If a language parameter was specified in the Place Details request, the Places Service will format and localize the opening hours appropriately for that language. The ordering of the elements in this array depends on the language parameter. Some languages start the week on Monday while others start on Sunday.
                public var weekdayText: [String] = []
                
                public init() {}
                public init?(map: Map) { }
                
                public mutating func mapping(map: Map) {
                    openNow <- map["open_now"]
//                    periods <- map["periods"]
                    weekdayText <- map["weekday_text"]
                }
                
                public struct Period: Mappable {
                    /// a pair of day and time objects describing when the place opens
                    public var open: DayTime?
                    
                    /// may contain a pair of day and time objects describing when the place closes. Note: If a place is always open, the close section will be missing from the response. Clients can rely on always-open being represented as an open period containing day with value 0 and time with value 0000, and no close.
                    public var close: DayTime?
                    
                    public init() {}
                    public init?(map: Map) { }
                    
                    public mutating func mapping(map: Map) {
                        open <- map["open"]
                        close <- map["close"]
                    }
                    
                    public struct DayTime: Mappable {
                        /// a number from 0–6, corresponding to the days of the week, starting on Sunday. For example, 2 means Tuesday.
                        public var day: Int?
                        
                        /// contain a time of day in 24-hour hhmm format. Values are in the range 0000–2359. The time will be reported in the place’s time zone.
                        public var time: Int?
                        
                        public init() {}
                        public init?(map: Map) { }
                        
                        public mutating func mapping(map: Map) {
                            day <- map["day"]
                            time <- map["time"]
                        }
                    }
                }
            }
            
            public struct Photo: Mappable {
                /// a string used to identify the photo when you perform a Photo request.
                public var photoReference: String?
                
                /// the maximum height of the image.
                public var height: Float?
                
                /// the maximum width of the image.
                public var width: Float?
                
                /// contains any required attributions. This field will always be present, but may be empty.
                public var htmlAttributions: [String] = []
                
                public init() {}
                public init?(map: Map) { }
                
                public mutating func mapping(map: Map) {
                    photoReference <- map["photo_reference"]
                    height <- map["height"]
                    width <- map["width"]
                    htmlAttributions <- map["html_attributions"]
                }
            }

            /**
             The price level of the place, on a scale of 0 to 4. The exact amount indicated by a specific value will vary from region to region.
             
             - free:          Free
             - inexpensive:   Inexpensive
             - moderate:      Moderate
             - expensive:     Expensive
             - veryExpensive: Very Expensive
             */
            public enum PriceLevel: Int {
                case free = 0
                case inexpensive = 1
                case moderate = 2
                case expensive = 3
                case veryExpensive = 4
            }
                
        }
    }
}
