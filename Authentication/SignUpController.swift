//
//  SignUpController.swift
//  Reperio
//
//  Created by Asif Saeed on 4/17/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Permission
import TinyConstraints
import SkyFloatingLabelTextField
import ShadowView
import SwiftMessages
import ImagePicker

class SignUpController: UIViewController {

  // CONSTANTS & VARIABLES

  let width = UIScreen.main.bounds.width
  let height = UIScreen.main.bounds.height
  let permission: Permission = .locationWhenInUse

  var imagePicked = false

  // OVERRIDES & VIEWS

  let signInTapped: UIButton = {
    let getStarted = UIButton()
    getStarted.setImage(#imageLiteral(resourceName: "SignIn"), for: .normal)
    getStarted.imageView?.contentMode = .scaleAspectFill
    getStarted.addTarget(self, action: #selector(sendToSignIn), for: .touchUpInside)
    return getStarted
  }()

  let profilePicTapped: UIButton = {
    let getStarted = UIButton()
    getStarted.clipsToBounds = true
    getStarted.setImage(#imageLiteral(resourceName: "AddProfilePhoto"), for: .normal)
    getStarted.imageView?.contentMode = .scaleAspectFill
    getStarted.addTarget(self, action: #selector(displayImagePicker), for: .touchUpInside)
    return getStarted
  }()

  let privacyPolicyTapped: UIButton = {
    let getStarted = UIButton()
    getStarted.setImage(#imageLiteral(resourceName: "privacyPolicy"), for: .normal)
    getStarted.imageView?.contentMode = .scaleAspectFill
    //    getStarted.addTarget(self, action: #selector(sendToSignUp), for: .touchUpInside)
    return getStarted
  }()

  let pushToPreferences: UIButton = {
    let getStarted = UIButton()
    getStarted.setImage(#imageLiteral(resourceName: "LoginPressed"), for: .normal)
    getStarted.imageView?.contentMode = .scaleAspectFit
    getStarted.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    return getStarted
  }()

  let googleTapped: UIButton = {
    let getStarted = UIButton()
    getStarted.setImage(#imageLiteral(resourceName: "Google"), for: .normal)
    getStarted.imageView?.contentMode = .scaleAspectFit
    getStarted.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
    return getStarted
  }()

  let facebookTapped: UIButton = {
    let getStarted = UIButton()
    getStarted.setImage(#imageLiteral(resourceName: "Facebook"), for: .normal)
    getStarted.imageView?.contentMode = .scaleAspectFit
    getStarted.addTarget(self, action: #selector(signInWithFacebook), for: .touchUpInside)
    return getStarted
  }()

  let container: Container = {
    let container = Container(radius: 8)
    container.shadowColor = .black
    container.shadowRadius = 15
    container.shadowOffset = CGSize.zero
    container.shadowOpacity = 0.25
    return container
  }()

  let background: UIImageView = {
    let contentView = UIImageView()
    contentView.image = #imageLiteral(resourceName: "AuthBackground")
    contentView.contentMode = .scaleAspectFill
    return contentView
  }()

  let fullName: AuthTextField = {
    let fullName = AuthTextField(placeholder: "NAME", type: UIKeyboardType.default)
    fullName.textContentType = UITextContentType.name
    fullName.autocapitalizationType = .words
    return fullName
  }()

  let email: AuthTextField = {
    let email = AuthTextField(placeholder: "EMAIL", type: UIKeyboardType.emailAddress)
    email.textContentType = UITextContentType.emailAddress
    email.autocapitalizationType = .none
    return email
  }()

  let password: AuthTextField = {
    let password = AuthTextField(placeholder: "PASSWORD", type: UIKeyboardType.default)
    password.autocapitalizationType = .none
    password.isSecureTextEntry = true
    return password
  }()

  let errorAlert: MessageView = {
    let success = MessageView.viewFromNib(layout: .cardView)
    success.configureTheme(.error)
    success.configureBackgroundView(width: App.width * 0.84)
    success.configureDropShadow()
    success.button?.setTitle("SWIPE", for: .normal)
    success.button?.addTarget(self, action: #selector(hideAlert), for: .touchUpInside)
    return success
  }()

  let textFields: UIView = UIView()

  lazy var fields: [AuthTextField] = [fullName, email, password]

  let orUser: UIImageView = {
    let view = UIImageView()
    view.image = #imageLiteral(resourceName: "socialLoginsLabel")
    view.contentMode = .scaleAspectFill
    return view
  }()

  let socialLogins: UIView = UIView()

  lazy var socials: [UIButton] = [facebookTapped, googleTapped]

  // LOCAL FUNCTIONS:

//  @objc func displayImagePicker() {
//    let imagePickerController = ImagePickerController()
//    imagePickerController.imageLimit = 1
//    imagePickerController.delegate = self
//    present(imagePickerController, animated: true, completion: nil)
//  }
  
  @objc func displayImagePicker() {
    var config = YPImagePickerConfiguration()
    config.onlySquareImagesFromCamera = true
    config.onlySquareImagesFromLibrary = true
    config.screens = [.photo, .library]
    config.showsFilters = true
    config.shouldSaveNewPicturesToAlbum = false
    config.videoCompression = AVAssetExportPresetHighestQuality
    config.startOnScreen = .photo
    
    
    // Build a picker with your configuration
    let picker = YPImagePicker(configuration: config)
    picker.isPosting = false
    
    picker.didSelectImage = { [unowned picker] img in
      // image picked
      print(img.size)
      self.profilePicTapped.setImage(img, for: .normal)
      self.profilePicTapped.layer.cornerRadius = self.profilePicTapped.frame.height / 2
      self.profilePicTapped.layer.masksToBounds = true
      self.imagePicked = true
      picker.dismiss(animated: true, completion: nil)
    }
    
    present(picker, animated: false, completion: nil)
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

  @objc func sendToSignIn() {
    let vc = SignInController()
    vc.view.layoutIfNeeded()
    self.present(vc, animated: false, completion: nil)
  }

  @objc func signUp() {
    if (permission.status == .authorized) && (imagePicked) {
      Auth.auth().fetchProviders(forEmail: (email.text)!) { (authMethods, error) in
        if error == nil {
          if authMethods != nil {

            self.email.errorMessage = "EMAIL IS ALREADY IN USE"
            print("EMAIL ERROR: Email is already in use.")

          } else if (!AuthTextField.validateEmail(Input: self.email.text!)) {

            self.email.errorMessage = "ENTER VALID EMAIL"

          } else if (self.fullName.text == "") {

            self.fullName.errorMessage = "ENTER YOUR NAME"

          } else if (self.password.text == "") {

            self.password.errorMessage = "ENTER A PASSWORD"

          } else if ((self.password.text?.count)! < 6) {

            self.password.errorMessage = "PASSWORD TOO SHORT"

          } else {

            self.registerUser()

          }
        } else {
          self.email.errorMessage = "ENTER VALID EMAIL"
          print("EMAIL ERROR: Enter valid email")
        }
      }
    } else if !imagePicked {
      self.errorAlert.configureContent(title: "No Photo Picked.", body: "Please add a profile picture to continue.")
      self.presentAlert()
    } else {
      locationPermissions()
    }
  }

  @objc func signInWithFacebook() {
    if (permission.status == .authorized) && (imagePicked) {

      let facebookLogin = FBSDKLoginManager()

      print("Logging In")

      facebookLogin.logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { (facebookResult, facebookError) -> Void in

        if facebookError != nil {

          print("Facebook login failed.Error \(facebookError!)")
          self.errorAlert.configureContent(title: "Alert!", body: "\(facebookError?.localizedDescription as String?)")
          self.presentAlert()

        } else if (facebookResult?.isCancelled)! {

          print("Facebook login was cancelled.")

        } else {

          self.getFBUserData()

        }
      })
    } else if !imagePicked {
      self.errorAlert.configureContent(title: "No Photo Picked.", body: "Please add a profile picture to continue.")
      self.presentAlert()
    } else {
      locationPermissions()
    }
  }

  func getFBUserData() {
    let accessToken = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
    Auth.auth().signIn(with: accessToken) { (user, error) in
      if error != nil {

        print("Login Failed, \(error!)")
        self.errorAlert.configureContent(title: "Alert!", body: "\(error?.localizedDescription as String?)")
        self.presentAlert()

      } else {
        
        let userRef = Api.User.usersRef.document((user?.uid)!)
        
        userRef.getDocument { (document, error) in
          if let document = document, document.exists {
            print("User exists.")
            self.sendHome()
          } else {
            
            FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: {
              (connection, result, error) -> Void in
              if error == nil && result != nil {
                
                let dict = result as! NSDictionary
                let name = dict.value(forKey: "name") as! String
                let email = dict.value(forKey: "email") as! String
                
                let values = [
                  "name": name as String,
                  "email": email as String,
                  "profilePic": self.profilePicTapped.currentImage!
                  ] as [String: AnyObject]
                
                self.sendToSignUpPreferences(values: values)
                
              } else {
                
                print("\(error?.localizedDescription as String?)")
                self.errorAlert.configureContent(title: "Alert!", body: "\(error?.localizedDescription as String?)")
                self.presentAlert()
                
              }
            })
          }
        }
      }
    }
  }

  @objc func signInWithGoogle() {
    if (permission.status == .authorized) && (imagePicked) {
      let shared = GIDSignIn.sharedInstance()
      shared?.delegate = self
      shared?.shouldFetchBasicProfile = true;
      shared?.delegate = self;
      shared?.uiDelegate = self;
      shared?.signIn()
    } else if !imagePicked {
      self.errorAlert.configureContent(title: "No Photo Picked.", body: "Please add a profile picture to continue.")
      self.presentAlert()
    } else {
      locationPermissions()
    }
  }

  func registerUser(){
    let values = [
      "name": self.fullName.text!,
      "email": self.email.text!,
      "password": self.password.text!,
      "profilePic": self.profilePicTapped.currentImage!
      ] as [String : AnyObject]
    self.sendToSignUpPreferences(values: values)
  }

  func sendToSignUpPreferences(values: [String: AnyObject]) {
    let vc = PreferencesController()
    vc.userInfo = values
    vc.view.layoutIfNeeded()
    present(vc, animated: false, completion: nil)
  }

  func sendHome() {
    guard let mainTabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
    mainTabBar.dismiss(animated: false) {
      mainTabBar.presentLaunchView(isLoading: true)
    }
  }

  func locationPermissions() {
    permission.request { (status) in
      switch status {
      case .authorized:    print("authorized")
      case .denied:        print("denied")
      case .disabled:      print("disabled")
      case .notDetermined: print("not determined")
      }
    }
  }

  func appAlreadyLaunchedOnce() {
    let defaults = UserDefaults.standard

    if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
      print("App already launched : \(isAppAlreadyLaunchedOnce)")
    } else {
      defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
      print("App launched first time")
    }

  }

  func layoutSubViews() {
    view.addSubview(background)
    background.edges(to: view)

    view.addSubview(container)
    container.width(width * 0.84)
    container.height(height * 0.415)
    container.centerX(to: view)
    container.top(to: view, offset: height * 0.33)

    let profileSize = height * 0.115
    view.addSubview(profilePicTapped)
    profilePicTapped.top(to: view, offset: height * 0.145)
    profilePicTapped.height(profileSize)
    profilePicTapped.width(profileSize)
    profilePicTapped.centerX(to: view)

    let signInWidth = width * 0.15
    view.addSubview(signInTapped)
    signInTapped.top(to: view, offset: height * 0.07)
    signInTapped.right(to: view, offset: -(width * 0.055))
    signInTapped.width(signInWidth)
    signInTapped.height(signInWidth * 0.283)

    let privacyWidth = width * 0.27
    view.addSubview(privacyPolicyTapped)
    privacyPolicyTapped.topToBottom(of: container, offset: height * 0.1)
    privacyPolicyTapped.left(to: container)
    privacyPolicyTapped.width(privacyWidth)
    privacyPolicyTapped.height(privacyWidth * 0.09)

    let btnSize = width * 0.205
    view.addSubview(pushToPreferences)
    pushToPreferences.centerY(to: privacyPolicyTapped)
    pushToPreferences.right(to: container)
    pushToPreferences.width(btnSize)
    pushToPreferences.height(btnSize)
  }

  func setUpContainer() {
    container.addSubview(fullName)
    fullName.delegate = self
    container.addSubview(email)
    email.delegate = self
    container.addSubview(password)
    password.delegate = self

    container.addSubview(textFields)
    textFields.top(to: container, offset: height * 0.05)
    textFields.width(width * 0.6267)
    textFields.height(height * 0.21)
    textFields.centerX(to: container)
    textFields.stack(fields, axis: .vertical, height: height * 0.05, spacing: height * 0.03)

    let widthOrUser = width * 0.12
    container.addSubview(orUser)
    orUser.topToBottom(of: textFields, offset: height * 0.075)
    orUser.width(widthOrUser)
    orUser.height(widthOrUser * 0.0289)
    orUser.left(to: textFields)

    let socialSize = width * 0.112
    container.addSubview(socialLogins)
    socialLogins.width(width * 0.264)
    socialLogins.height(socialSize)
    socialLogins.stack(socials, axis: .horizontal, width: socialSize, spacing: width * 0.04)
    socialLogins.centerY(to: orUser)
    socialLogins.right(to: textFields)
  }
  
  // VIEW FUNCTIONS:

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.isNavigationBarHidden = true
    GIDSignIn.sharedInstance().delegate = self
    layoutSubViews()
    setUpContainer()
    locationPermissions()
    appAlreadyLaunchedOnce()
  }

}

extension SignUpController: UITextFieldDelegate {

  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == email {
      email.errorMessage = nil
    } else if textField == password {
      password.errorMessage = nil
    } else if textField == fullName {
      fullName.errorMessage = nil
    }
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == email {
      email.errorMessage = nil
      let emailText = email.text
      if !((email.text?.count)! == 0) && !(AuthTextField.validateEmail(Input: emailText!)) {
        email.errorMessage = "EMAIL IS INVALID"
      }
    } else if textField == password {
      password.errorMessage = nil
      if !((password.text?.count)! == 0) && (password.text?.count)! < 6 {
        password.errorMessage = "PASSWORD TOO SHORT"
      }
    } else if textField == fullName {
      fullName.errorMessage = nil
      if !((fullName.text?.count)! == 0) && (fullName.text?.count)! < 2 {
        fullName.errorMessage = "ENTER YOUR FULL NAME"
      }
    }
  }

}

extension SignUpController: GIDSignInDelegate, GIDSignInUIDelegate {

  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if let error = error {
      print(error.localizedDescription)
      return
    }

    let fullName = user.profile.name
    let email = user.profile.email

    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                   accessToken: authentication.accessToken)
    Auth.auth().signIn(with: credential) { (user, error) in

      if let error = error {

        print(error)

        return

      } else {

        let userRef = Api.User.usersRef.document((user?.uid)!)
        
        userRef.getDocument { (document, error) in
          if let document = document, document.exists {
            print("User exists.")
            self.sendHome()
          } else {
            print("User doesn't exist.")
            let values = [
              "name": fullName!,
              "email": email!,
              "profilePic": self.profilePicTapped.currentImage!
              ] as [String : AnyObject]
            self.sendToSignUpPreferences(values: values)
          }
        }
      }
    }
  }

}

extension SignUpController: ImagePickerDelegate {

  func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {

  }

  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    let image = images.first
    dismiss(animated: true) {
      self.profilePicTapped.setImage(image, for: .normal)
      self.profilePicTapped.layer.cornerRadius = self.profilePicTapped.frame.height / 2
      self.profilePicTapped.layer.masksToBounds = true
      self.imagePicked = true
    }
  }

  func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    dismiss(animated: true, completion: nil)
  }

}
