//
//  PreferencesController.swift
//  Reperio
//
//  Created by Asif Saeed on 4/17/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import UIKit
import Firebase
import TinyConstraints
import SkyFloatingLabelTextField
import ShadowView
import SwiftMessages
import BulletinBoard

class PreferencesController: UIViewController {
  
  // CONSTANTS:
  
  var userInfo = [String: AnyObject]()
  var preferences = [String]()
  
  // VIEWS:
  
  let pageTitle: UIImageView = {
    let title = UIImageView()
    title.image = #imageLiteral(resourceName: "FoodPreferencesTitle")
    title.contentMode = .scaleAspectFill
    return title
  }()
  
  let background: UIImageView = {
    let view = UIImageView()
    view.image = #imageLiteral(resourceName: "AuthBackground")
    view.contentMode = .scaleAspectFill
    return view
  }()
  
  let pushToHome: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "LoginPressed"), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.addTarget(self, action: #selector(finishRegistering), for: .touchUpInside)
    return button
  }()
  
  let errorAlert: MessageView = {
    let success = MessageView.viewFromNib(layout: .cardView)
    success.configureTheme(.error)
    success.configureBackgroundView(width: App.width * 0.84)
    success.configureDropShadow()
    success.button?.setTitle("OK", for: .normal)
    success.button?.addTarget(self, action: #selector(hideAlert), for: .touchUpInside)
    return success
  }()
  
  lazy var termsAttributedString: NSMutableAttributedString = {
    let termsAttributedString = NSMutableAttributedString(string: "By creating an account, you agree to the Reperio Terms of Use ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)])
    termsAttributedString.setAttributes(App.termsAndConditionsAttributes, range: NSMakeRange(48, 12))
    termsAttributedString.append(privacyAttributedString)
    return termsAttributedString
  }()
  
  lazy var privacyAttributedString: NSMutableAttributedString = {
    let privacyAttributedString = NSMutableAttributedString(string: "and Privacy Policy.", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)])
    privacyAttributedString.setAttributes(App.privacyPolicyAttributes, range: NSMakeRange(4, 14))
    return privacyAttributedString
  }()
  
  lazy var acceptTermsAlert: BulletinManager = {
    let page = PageBulletinItem(title: "Accept Terms")
    page.image = UIImage(named: "...")
    page.descriptionText = termsAttributedString
    page.actionButtonTitle = "I Agree"
    page.alternativeButtonTitle = "Cancel"
    page.actionHandler = { (item: PageBulletinItem) in
      item.manager?.dismissBulletin()
      self.registerAction()
    }
    page.alternativeHandler = { (item: PageBulletinItem) in
      item.manager?.dismissBulletin()
    }
    return BulletinManager(rootItem: page)
  }()
  
  private let loadingContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.8)
    return view
  }()
  
  private let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    aiv.hidesWhenStopped = true
    aiv.translatesAutoresizingMaskIntoConstraints = false
    return aiv
  }()
  
  private let label: UILabel = {
    let frame = CGRect(x: 0, y: 0, width: 200, height: 20)
    let label = UILabel(frame: frame)
    label.text = NSLocalizedString("Processing...", comment: "Processing...")
    label.textColor = .white
    return label
  }()
  
  var collectionView: UICollectionView!
  
  // FUNCTIONS:
  
  
  private func setupActivityIndicator() {
    self.view.addSubview(loadingContainerView)
    loadingContainerView.alpha = 0
    loadingContainerView.frame = self.view.bounds
    
    loadingContainerView.addSubview(label)
    let labelWidth: CGFloat = 200.0
    let labelHeight: CGFloat = 20.0
    let offset: CGFloat = 40.0
    let frame = CGRect(x: (loadingContainerView.frame.width/2) - offset,
                       y: (loadingContainerView.frame.height/2) + offset,
                       width: labelWidth,
                       height: labelHeight)
    label.frame = frame
    
    loadingContainerView.addSubview(activityIndicatorView)
    activityIndicatorView.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor).isActive = true
    activityIndicatorView.centerYAnchor.constraint(equalTo: loadingContainerView.centerYAnchor).isActive = true
  }
  
  func showHideActivityIndicator() {
    
    if !activityIndicatorView.isAnimating {
      activityIndicatorView.startAnimating()
      loadingContainerView.alpha = 1
    } else {
      activityIndicatorView.stopAnimating()
      loadingContainerView.alpha = 0
    }
  }
  
  func appendPreferences() {
    preferences.removeAll()
    for index in collectionView.indexPathsForSelectedItems! {
      let pref = App.preferences[index.item]
      preferences.append(pref)
    }
    print(preferences)
  }
  
  func registerAction() {
    showHideActivityIndicator()
    if preferences.isEmpty {
      
      print("Empty Preferences.")
      showHideActivityIndicator()
      self.errorAlert.configureContent(title: "Empty Preferences", body: "Please select your preference(s).")
      self.presentAlert()
      
    } else {
      
      if (Auth.auth().currentUser) == nil {
        Auth.auth().createUser(withEmail: self.userInfo["email"] as! String, password: self.userInfo["password"] as! String, completion: { (user, error) in
          if error == nil {
            self.registerUser()
          } else {
            print("Error creating new user.")
            self.showHideActivityIndicator()
            self.errorAlert.configureContent(title: "Alert!", body: "\((error?.localizedDescription)!)")
            self.presentAlert()
            return
          }
        })
      } else {
        registerUser()
      }
    }
  }
  
  func registerUser() {
    let storageRef = App.RefStorageProfPics.child((Auth.auth().currentUser!.uid))
    let profPic = self.userInfo["profilePic"]! as! UIImage
    let imageData = UIImageJPEGRepresentation(profPic, 0.2)
    storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
      if err == nil {
        
        let path = metadata?.downloadURL()?.absoluteString
        let newUser: [String: Any] = [
          "email": self.userInfo["email"]!,
          "likes": 0,
          "name": self.userInfo["name"]!,
          "preferences": self.preferences,
          "profilePicLink": path!,
          "redeemedDeals": [:] as [String : Bool],
          "savedDeals": [:] as [String : Bool]
          ]
        print(newUser)
        
        let userRef = Api.User.usersRef.document((Auth.auth().currentUser?.uid)!)
        
        userRef.setData(
          newUser
        ) { err in
          if let err = err {
            print("Error saving data to database: \(err)")
            self.showHideActivityIndicator()
            self.errorAlert.configureContent(title: "Alert!", body: "\(err)")
            self.presentAlert()
          } else {
            print("registered")
            self.showHideActivityIndicator()
            self.sendHome()
            
          }
        }
        
      } else {
        print("Error saving data to storage: \(err!)")
        self.showHideActivityIndicator()
        self.errorAlert.configureContent(title: "Alert!", body: "\((err?.localizedDescription)!)")
        self.presentAlert()
        
      }
      
    })
    
  }
  
  func sendHome() {
    let vc = MainTabBarController()
    AppDelegate.sharedInstance().window?.rootViewController = vc
    guard let mainTabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
    mainTabBar.dismiss(animated: false) {
      mainTabBar.presentLaunchView(isLoading: true)
    }
  }
  
  @objc func finishRegistering() {
    
    acceptTermsAlert.prepare()
    acceptTermsAlert.presentBulletin(above: self)
    
  }
  
  @objc func hideAlert() {
    SwiftMessages.hide()
  }
  
  func presentAlert() {
    var successConfig = SwiftMessages.defaultConfig
    successConfig.presentationStyle = .center
    successConfig.duration = .forever
    successConfig.dimMode = .blur(style: .dark, alpha: 0.6, interactive: true)
    successConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
    errorAlert.layoutIfNeeded()
    SwiftMessages.show(config: successConfig, view: errorAlert)
  }
  
  func layoutSubViews() {
    
    view.addSubview(background)
    background.edges(to: view)
    
    view.addSubview(pageTitle)
    let titleWidth = App.width * 0.7
    let titleHeight = titleWidth * 0.08
    let topHeight = ((App.height - (App.width * 1.26)) / 2)
    let titleOffset = ((topHeight - titleHeight) / 2)
    pageTitle.top(to: view.layoutMarginsGuide, offset: titleOffset)
    pageTitle.centerXToSuperview()
    pageTitle.width(titleWidth)
    pageTitle.height(titleHeight)
    
    view.addSubview(pushToHome)
    let btnSize = App.width * 0.205
    let bottomHeight = ((App.height - (App.width * 1.08)) / 2)
    let btnOffset = ((bottomHeight - btnSize) / 2)
    pushToHome.bottomToSuperview(offset: -(btnOffset))
    pushToHome.rightToSuperview(offset: App.width * 0.05)
    pushToHome.width(btnSize)
    pushToHome.height(btnSize)
    
    let cellWidth = ((App.width * 0.8) / 3)
    let cellHeight = (App.width * 1.04 / 4)
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
    layout.minimumLineSpacing = (App.width * 0.04)
    let collectionFrame = CGRect(x: (0.05), y: (topHeight), width: (App.width * 0.9), height: (App.width * 1.26))
    collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
    collectionView.register(PreferenceCell.self, forCellWithReuseIdentifier: "MyCell")
    collectionView.allowsMultipleSelection = true
    collectionView.backgroundColor = .clear
    
    view.addSubview(collectionView)
    collectionView.width(App.width * 0.9)
    collectionView.height(App.width * 1.26)
    collectionView.centerInSuperview()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    setupActivityIndicator()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.isNavigationBarHidden = true
    layoutSubViews()
    print(userInfo)
  }
  
}

extension PreferencesController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return App.preferences.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath as IndexPath) as! PreferenceCell
    let pref = App.preferences[indexPath.item]
    cell.updateView(labelText: pref, image: UIImage(named: "\(pref)Search")!)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Selected item \(indexPath.row)")
    let cell = collectionView.cellForItem(at: indexPath) as! PreferenceCell
    cell.select()
    print(collectionView.indexPathsForSelectedItems!)
    appendPreferences()
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    print("Unselected item \(indexPath.row)")
    let cell = collectionView.cellForItem(at: indexPath) as! PreferenceCell
    cell.unselect()
    appendPreferences()
  }
  
}
