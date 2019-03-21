//
//  HomeController.swift
//  Reperio
//
//  Created by Asif Saeed on 4/26/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import CoreLocation
import MapKit
import SDWebImage
import Alamofire

class HomeController: UIViewController {
  
  // CONSTANTS & VARIABLES
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  var currentUser = User()

  var restaurantsDetailArray: [GooglePlaces.PlaceDetailsResponse?] = []
  var restaurants: [Restaurant] = []
  var restaurantsWithDeals: [Restaurant] = []
  var locationInfo = CLLocation()
  var restaurantIDs: [String] = []
  
  var locationManager = CLLocationManager()
  var latitude: NSNumber?
  var longitude: NSNumber?
  var locationAddress = String()
  
  var photoArray: [UIImage] = [UIImage(named: "WalkPicture1")!, UIImage(named: "WalkPicture2")!, UIImage(named: "WalkPicture3")!]
  var nameArray: [String] = ["Graziano's Gourmet in Weston", "Ceviche Arigato", "Acqualina"]
  var infoArray: [String] = ["Open Now • 0.3 miles from you • $$$", "Open Now • 0.9 miles from you • $$", "Closed • 1.2 miles from you • $$$"]
  var headerMinimumHeight = App.DynamicNavigationHeight + 20
  var headerHeight = App.DynamicNavigationHeight + 75
  var layout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 15
    layout.minimumLineSpacing = 15
    return layout
  }()
  var lastVerticalOffset: CGFloat = 0
  var topConstraintHeaderContainer: Constraint? = nil
  var refreshNearby = UIRefreshControl()
  var refreshDeals = UIRefreshControl()
  var nearbySelected = true
  var scrollOffset = CGFloat()
  var scrollOffsetNearby: CGFloat = App.DynamicNavigationHeight + 140
  var scrollOffsetDeals: CGFloat = App.DynamicNavigationHeight + 140
//  lazy var collectionViews = [UICollectionView]
  
  // OVERRIDES & VIEWS
  
  let headerContainer: UIView = {
    let view  = UIView()
    view.backgroundColor = App.blue
    view.layer.shadowOffset = CGSize(width: 0, height: 50)
    view.layer.shadowRadius = 10
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.25
    view.layer.masksToBounds = false
    return view
  }()
  
  let headerContainerTop: UIView = {
    let view  = UIView()
    view.backgroundColor = App.blue
    return view
  }()
  
  let headerLabel: UILabel = {
    let titleLabel  = UILabel()
    titleLabel.text = "Restaurants"
    titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
    titleLabel.textColor = UIColor.white
    return titleLabel
  }()
  
  let headerLabelTop: UILabel = {
    let titleLabel  = UILabel()
    titleLabel.text = "Restaurants"
    titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
    titleLabel.textColor = UIColor.white
    return titleLabel
  }()
  
  let topTabBar: TopTabView = {
    let tab = TopTabView(leftTitle: "Nearby", rightTitle: "Deals")
    return tab
  }()
  
  var placeholderImage: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    view.isHidden = true
    return view
  }()
  
  var nearbyCollectionView: UICollectionView!
  var dealsCollectionView: UICollectionView!
  
  // VIEW FUNCTIONS
  
  func loadOrganizedRestaurants() {
    restaurants.removeAll()
    restaurantIDs.removeAll()
    var index = 1
    for rest in restaurantsDetailArray {
      let restInit = Restaurant()
      let restID = (rest?.result?.placeID)!
      print("RESTAURANT HAS REPEAT = \(restaurantIDs.contains(restID))")
      index = index + 1
      if !((rest?.result?.photos.isEmpty)!) && (rest?.result?.rating != nil) && !(restaurantIDs.contains(restID)) {
        restaurantIDs.append(restID)
        restInit.transform(fromGoogle: rest, currentLocation: locationInfo) { (restInfo) in
          self.restaurants.append(restInfo)
          self.nearbyCollectionView.reloadData()
          self.organizeByDistance()
        }
      }
    }
  }
  
  func organizeByDistance() {
    restaurants.sort {
      $0.distanceSpec! < $1.distanceSpec!
    }
  }
  
  func organizeDealsByDistance() {
    restaurantsWithDeals.sort {
      $0.distanceSpec! < $1.distanceSpec!
    }
  }
  
  func loadRestaurantsWithDeals() {
    restaurantsWithDeals.removeAll()
    for rest in restaurants {
      let dealRef = Api.Deal.dealsRef.whereField("restaurantID", isEqualTo: rest.placeID!).whereField("active", isEqualTo: true)
      dealRef.getDocuments { (querySnapshot, err) in
        if let err = err {
          print("RESTAURANT DOESN'T HAVE DEALS: \(rest.name)")
          print("Error getting documents: \(err)")
        } else {
          if !((querySnapshot?.documents.isEmpty)!) {
            self.restaurantsWithDeals.append(rest)
            self.organizeDealsByDistance()
            self.dealsCollectionView.reloadData()
          }
        }
      }
    }
  }
  
  @objc func reloadNearby() {
    if !refreshNearby.isRefreshing {
      locationManager.startUpdatingLocation()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      self.refreshNearby.endRefreshing()
    }
  }
  
  @objc func reloadDeals() {
    if !refreshDeals.isRefreshing {
      loadRestaurantsWithDeals()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.dealsCollectionView.reloadData()
      self.refreshDeals.endRefreshing()
    }
  }
  
  @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {
      switch swipeGesture.direction {
      case UISwipeGestureRecognizerDirection.right:
        self.topTabBar.leftButtonClicked()
        
      case UISwipeGestureRecognizerDirection.left:
        self.topTabBar.rightButtonClicked()
        
      default:
        break
      }
    }
  }
  
  func updateLocation(){
    let userRef = Api.User.usersRef.document((Auth.auth().currentUser?.uid)!)
    let newLocation:[String: Any] = ["latitude": latitude!, "location": locationAddress, "longitude": longitude!]
    
    userRef.updateData(
      newLocation
    ) { err in
      if let err = err {
        print("Error saving data to database: \(err)")
      } else {
        print("Location Updated.")
      }
    }
    
  }
  
  func layoutViews() {
    
    nearbyCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let insetHeight = (headerHeight + 65) - statusBarHeight
    nearbyCollectionView.contentInset = UIEdgeInsets(top: insetHeight, left: 15, bottom: 15, right: 15)
    lastVerticalOffset = nearbyCollectionView.contentOffset.y
    nearbyCollectionView.delegate = self
    nearbyCollectionView.dataSource = self
    nearbyCollectionView.backgroundColor = UIColor.white
    nearbyCollectionView.register(HomeFeedCell.self, forCellWithReuseIdentifier: "HomeFeedCell")
    refreshNearby.addTarget(self, action: #selector(reloadNearby), for: UIControlEvents.valueChanged)
    nearbyCollectionView.refreshControl = refreshNearby
    nearbyCollectionView.refreshControl?.bounds = CGRect(x: refreshNearby.bounds.origin.x + 15, y: refreshNearby.bounds.origin.y, width: refreshNearby.bounds.size.width, height: refreshNearby.bounds.size.height)
    nearbyCollectionView.showsVerticalScrollIndicator = false
    view.addSubview(nearbyCollectionView)
    nearbyCollectionView.snp.makeConstraints { (m) in
      m.left.equalTo(self.view).constraint
      m.width.top.bottom.equalToSuperview()
    }
    
    dealsCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
    dealsCollectionView.contentInset = UIEdgeInsets(top: insetHeight, left: 15, bottom: 15, right: 15)
    lastVerticalOffset = dealsCollectionView.contentOffset.y
    dealsCollectionView.alpha = 0.5
    dealsCollectionView.delegate = self
    dealsCollectionView.dataSource = self
    dealsCollectionView.backgroundColor = UIColor.white
    dealsCollectionView.register(HomeFeedCell.self, forCellWithReuseIdentifier: "HomeFeedCell")
    refreshDeals.addTarget(self, action: #selector(reloadDeals), for: UIControlEvents.valueChanged)
    dealsCollectionView.refreshControl = refreshDeals
    dealsCollectionView.refreshControl?.bounds = CGRect(x: refreshDeals.bounds.origin.x + 15, y: refreshDeals.bounds.origin.y, width: refreshDeals.bounds.size.width, height: refreshDeals.bounds.size.height)
    dealsCollectionView.showsVerticalScrollIndicator = false
    view.addSubview(dealsCollectionView)
    dealsCollectionView.snp.makeConstraints { (m) in
      m.width.top.bottom.equalToSuperview()
      m.left.equalTo(self.nearbyCollectionView.snp.right)
    }
    
    view.addSubview(headerContainer)
    headerContainer.snp.makeConstraints { (m) in
      topConstraintHeaderContainer = m.top.equalTo(self.view).constraint
      m.left.right.equalTo(self.view)
      m.height.equalTo(headerHeight)
    }
    headerContainer.addSubview(headerLabel)
    headerLabel.snp.makeConstraints { (m) in
      m.left.equalTo(self.headerContainer).offset(20)
      m.bottom.equalTo(self.headerContainer).offset(-20)
    }
    view.addSubview(topTabBar)
    topTabBar.snp.makeConstraints { (m) in
      m.top.equalTo(self.headerContainer.snp.bottom)
      m.height.equalTo(50)
      m.width.centerX.equalTo(self.view)
    }
    topTabBar.delegate = self
    
    view.addSubview(headerContainerTop)
    headerContainerTop.snp.makeConstraints { (m) in
      m.left.top.right.equalTo(self.view)
      m.height.equalTo(headerMinimumHeight)
    }
    headerContainerTop.addSubview(headerLabelTop)
    headerLabelTop.snp.makeConstraints { (m) in
      m.centerX.equalTo(self.headerContainerTop)
      m.bottom.equalTo(self.headerContainerTop).offset(-20)
    }
    headerLabelTop.alpha = 0
    
    view.addSubview(placeholderImage)
    placeholderImage.snp.makeConstraints { (m) in
      m.centerX.equalToSuperview()
      m.centerY.equalToSuperview().offset(App.width * 0.1)
      m.width.equalTo(App.width * 0.8)
    }

  }

  override func viewDidLoad() {
    super.viewDidLoad()
    print("HEADER HEIGHT VIEWDIDLOAD \(headerHeight)")
    layoutViews()
    loadOrganizedRestaurants()
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
    swipeRight.direction = UISwipeGestureRecognizerDirection.right
    view.addGestureRecognizer(swipeRight)
    
    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
    swipeLeft.direction = UISwipeGestureRecognizerDirection.left
    view.addGestureRecognizer(swipeLeft)
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest

  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(false)
    loadRestaurantsWithDeals()
    print("HEADERHEIGHT VIEWDIDAPPEAR \(headerHeight)")
    print("HEADERCONTAINERHEIGHT VIEWDIDAPPEAR \(headerContainer.frame.height)")
    print("HEADER HEIGHT VIEWDIDAPPEAR \(headerHeight)")
    Api.User.observeCurrentUser { (user) in
      self.currentUser = user
    }
  }
}

extension HomeController: UIGestureRecognizerDelegate, TopTabViewDelegate {
  func leftButtonClicked() {
    print("Left TAB")
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
      self.placeholderImage.isHidden = true
      self.nearbySelected = true
      self.dealsCollectionView.transform = CGAffineTransform(translationX: 0, y: 0)
      self.dealsCollectionView.alpha = 0.0
      self.nearbyCollectionView.transform = CGAffineTransform(translationX: 0, y: 0)
      self.updateHeaderUI(self.scrollOffsetNearby)
    }) { (done) in
      self.nearbyCollectionView.reloadData()
      self.nearbyCollectionView.alpha = 1.0
    }
  }
  
  func rightButtonClicked() {
    print("RIGHT TAB")
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
      self.placeholderImage.isHidden = true
      self.nearbySelected = false
      self.nearbyCollectionView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
      self.nearbyCollectionView.alpha = 0.0
      self.dealsCollectionView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
      self.updateHeaderUI(self.scrollOffsetDeals)
    }) { (done) in
      self.dealsCollectionView.reloadData()
      self.dealsCollectionView.alpha = 1.0
    }
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
  
  func distanceFromYou(restaurantLocation: GoogleMapsService.LocationCoordinate2D) -> String {
    let pointLocation = CLLocation(latitude: CLLocationDegrees(restaurantLocation.latitude), longitude: CLLocationDegrees(restaurantLocation.longitude))
    let currentLocation = locationInfo
    let distance = currentLocation.distance(from: pointLocation)
    let formatter = MKDistanceFormatter()
    formatter.unitStyle = .default
    formatter.units = .imperial
    let distanceInMiles = formatter.string(fromDistance: distance)
    return distanceInMiles
  }
  
  
}

extension HomeController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if nearbySelected {
      if restaurants.count == 0 {
        placeholderImage.isHidden = false
        placeholderImage.image = #imageLiteral(resourceName: "LeaderboardNearbyPlaceholder")
        return 0
      } else {
        placeholderImage.isHidden = true
        return restaurants.count
      }
    } else if !(nearbySelected) && !(restaurantsWithDeals.isEmpty) {
      placeholderImage.isHidden = true
      return restaurantsWithDeals.count
    } else {
      placeholderImage.isHidden = false
      placeholderImage.image = #imageLiteral(resourceName: "HomeDealsPlaceholder")
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    var rest: Restaurant
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeFeedCell", for: indexPath) as! HomeFeedCell
    if nearbySelected {
      rest = restaurants[indexPath.row]
      cell.setupSubViews()
      cell.imageView.sd_setImage(with: rest.defaultPhoto!)
      cell.restaurantNameLabel.text = rest.name
      cell.restaurantInfoLabel.text = "\(rest.openNow!) • \(rest.distance!) \(rest.priceLevel!)"
      cell.rating.rating = rest.rating!
      //Using weak because otherwise will cause reference cycle
      return cell
    } else {
      rest = restaurantsWithDeals[indexPath.row]
      cell.setupSubViews()
      cell.imageView.sd_setImage(with: rest.defaultPhoto!)
      cell.restaurantNameLabel.text = rest.name
      cell.restaurantInfoLabel.text = "\(rest.openNow!) • \(rest.distance!) \(rest.priceLevel!)"
      cell.rating.rating = rest.rating!
      //Using weak because otherwise will cause reference cycle
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var rest: Restaurant
    if nearbySelected {
      rest = restaurants[indexPath.row]
    } else {
      rest = restaurantsWithDeals[indexPath.row]
    }
    let vc = RestaurantDetailController()
    vc.restaurant = rest
    vc.view.layoutIfNeeded()
    present(vc, animated: false, completion: nil)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = self.view.frame.width - 30
    return CGSize(width: width, height: width * 0.75)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let verticalOffset = scrollView.contentOffset.y
    let scrollAmount = verticalOffset - lastVerticalOffset  //get scrolling amount since last update
    lastVerticalOffset = verticalOffset
    
    scrollOffset = -verticalOffset //newConstant will be the updated value for the verticalSpaceConstraint constant
    
    if nearbySelected {
      scrollOffsetNearby = scrollOffset
    } else {
      scrollOffsetDeals = scrollOffset
    }
    
    updateHeaderUI(scrollOffset)
  }
  
  func updateHeaderUI(_ newConstant: CGFloat) {
    let maxOffset = headerHeight + 65
    let minOffset = headerMinimumHeight + 65
    let differenceMaxMin = maxOffset - minOffset
    let headerOffset = maxOffset - newConstant
    if (newConstant < maxOffset) && (newConstant > minOffset) {
      self.topConstraintHeaderContainer?.update(offset: -headerOffset)
    } else if (newConstant >= maxOffset) {
      self.topConstraintHeaderContainer?.update(offset: 0)
    } else if (newConstant <= minOffset) {
      self.topConstraintHeaderContainer?.update(offset: -differenceMaxMin)
    }
    
    if (newConstant < (minOffset + 20)) {
      UIView.animate(withDuration: 0.1) {
        self.headerLabelTop.alpha = 1.0
      }
    } else {
      UIView.animate(withDuration: 0.1) {
        self.headerLabelTop.alpha = 0
      }
    }
  }
  
}

extension HomeController: CLLocationManagerDelegate {
  
  // MARK: - Location Delegate Methods
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print()
    let location = locations.last
    let long = location!.coordinate.longitude;
    let lat = location!.coordinate.latitude;
    
    locationInfo = location!
    latitude = lat as NSNumber
    longitude = long as NSNumber
    
    let group = DispatchGroup()
    
    group.enter()
    let geoCoder = CLGeocoder()
    
    let loc = CLLocation(latitude: lat, longitude: long)
    geoCoder.reverseGeocodeLocation(loc, completionHandler: { placemarks, error in
      guard let addressDict = placemarks?[0].addressDictionary else {
        return
      }
      
      // Print each key-value pair in a new row
      //      addressDict.forEach { print($0) }
      
      // Print fully formatted address
      
      let cit = addressDict["City"] as! String
      let stat = addressDict["State"] as! String
      let countr = addressDict["CountryCode"] as! String
      
      let city = "\(cit)"
      let state = "\(stat)"
      let country = "\(countr)"
      
      var location = String()
      
      if country == "US" {
        location = "\(city), \(state)"
      } else {
        location = "\(city), \(country)"
      }
      
      self.locationAddress = location
      
      DispatchQueue.main.async {
        GoogleMapsService.provide(apiKey: "AIzaSyAwczS8LFjHVqNRFzAlXmuaGkHy3HmVz1M")
        //        let googleMapsCoordinates = GoogleMapsService.LocationCoordinate2D(latitude: lat as Double, longitude: long as Double)
        for pref in self.currentUser.preferences! {
          let url = ("https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(pref)&sensor=true&location=\(lat),\(long)&radius=10000&type=restaurant&key=AIzaSyAwczS8LFjHVqNRFzAlXmuaGkHy3HmVz1M")
          
          Alamofire.request(url).responseJSON { response in
            
            debugPrint(response)
            
            if let JSON = response.result.value {
              
              if (response.result.isSuccess) {
                
                let response = JSON as! NSDictionary
                print(response)
                
                //          self.locationArray = (response.value(forKey: "predictions") as! NSArray).value(forKey: "description") as! NSArray
                
                let placeIds = (response["results"] as! NSArray).value(forKey: "place_id") as! NSArray
                
                print("RESPONSE: \(placeIds)")
                for place in placeIds {
                  let placeID = "\(place)"
                  GooglePlaces.placeDetails(forPlaceID: placeID, extensions: nil, language: nil, completion: { (rests, err) in
                    self.restaurantsDetailArray.append(rests)
                    self.loadOrganizedRestaurants()
                  })
                }
              } else {
                
                print ("Error: \(response.result.error as! String)")
                
              }
            }
          }
        }
        
        self.updateLocation()
        group.leave()
      }
      
    })
    
    locationManager.stopUpdatingLocation()
  }
  
}
