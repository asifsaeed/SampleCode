//
//  SignInController.swift
//  Reperio
//
//  Created by Asif Saeed on 4/17/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Permission
import TinyConstraints
import SkyFloatingLabelTextField
import ShadowView
import SwiftMessages

class SignInController: UIViewController {
  
  // CONSTANTS:
  
  let width = UIScreen.main.bounds.width
  let height = UIScreen.main.bounds.height
  let permission: Permission = .locationWhenInUse
  
  // VIEWS:
  
  let signUpTapped: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "SignUp"), for: .normal)
    button.imageView?.contentMode = .scaleAspectFill
    button.addTarget(self, action: #selector(sendToSignUp), for: .touchUpInside)
    return button
  }()
  
  let profilePicTapped: UIImageView = {
    let view = UIImageView()
    view.image = #imageLiteral(resourceName: "ReperioLogo")
    view.contentMode = .scaleAspectFill
    return view
  }()
  
  let forgotPasswordTapped: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "ForgotPassword"), for: .normal)
    button.imageView?.contentMode = .scaleAspectFill
    button.addTarget(self, action: #selector(sendToForgotPassword), for: .touchUpInside)
    return button
  }()
  
  let pushToHome: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "LoginPressed"), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    return button
  }()
  
  let googleTapped: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "Google"), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
    return button
  }()
  
  let facebookTapped: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "Facebook"), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.addTarget(self, action: #selector(signInWithFacebook), for: .touchUpInside)
    return button
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
    let view = UIImageView()
    view.image = #imageLiteral(resourceName: "AuthBackground")
    view.contentMode = .scaleAspectFill
    return view
  }()
  
  let email: AuthTextField = {
    let email = AuthTextField(placeholder: "EMAIL", type: UIKeyboardType.emailAddress)
    email.textContentType = UITextContentType.emailAddress
    email.autocapitalizationType = .none
    email.autocorrectionType = .no
    return email
  }()
  
  let password: AuthTextField = {
    let password = AuthTextField(placeholder: "PASSWORD", type: UIKeyboardType.default)
    password.autocapitalizationType = .none
    password.autocorrectionType = .no
    password.isSecureTextEntry = true
    return password
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
  
  let signupAlert: MessageView = {
    let success = MessageView.viewFromNib(layout: .cardView)
    success.configureTheme(.error)
    success.configureBackgroundView(width: App.width * 0.84)
    success.configureDropShadow()
    success.button?.setTitle("SIGNUP", for: .normal)
    success.button?.addTarget(self, action: #selector(sendToSignUp), for: .touchUpInside)
    return success
  }()
  
  let textFields: UIView = UIView()
  
  lazy var fields: [AuthTextField] = [email, password]
  
  let orUser: UIImageView = {
    let view = UIImageView()
    view.image = #imageLiteral(resourceName: "socialLoginsLabel")
    view.contentMode = .scaleAspectFill
    return view
  }()
  
  let socialLogins: UIView = UIView()
  
  lazy var socials: [UIButton] = [facebookTapped, googleTapped]
  
  // FUNCTIONS:
  
  @objc func sendToSignUp() {
    let vc = SignUpController()
    vc.view.layoutIfNeeded()
    present(vc, animated: false, completion: nil)
    SwiftMessages.hide()
  }
  
  @objc func sendToForgotPassword() {
    let vc = ForgotPasswordController()
    vc.view.layoutIfNeeded()
    present(vc, animated: false, completion: nil)
  }
  
  @objc func hideAlert() {
    SwiftMessages.hide()
  }
  
  func presentSignupAlert() {
    var successConfig = SwiftMessages.defaultConfig
    successConfig.presentationStyle = .center
    successConfig.duration = .forever
    successConfig.dimMode = .blur(style: .dark, alpha: 0.6, interactive: true)
    successConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
    signupAlert.layoutIfNeeded()
    SwiftMessages.show(config: successConfig, view: signupAlert)
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
  
  @objc func signIn() {
    if (email.text == "") {
      
      email.errorMessage = "ENTER EMAIL"
      
    } else if (password.text == "") {
      
      password.errorMessage = "ENTER YOUR PASSWORD"
      
    } else {
      loginUser()
    }
  }
  
  func loginUser() {
    if permission.status == .authorized {
      Auth.auth().signIn(withEmail: email.text!, password: password.text!, completion: { (user, error) in
        
        if error == nil {
          
          self.sendHome()
          
        } else {
          
          self.errorAlert.configureContent(title: "Problem signing you in.", body: "Please try again.")
          self.presentAlert()
          
        }
      })
    } else {
      locationPermissions()
    }
  }
  
  @objc func signInWithFacebook() {
    if permission.status == .authorized {
      
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
    } else {
      locationPermissions()
    }
  }
  
  func getFBUserData() {
    let accessToken = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
    Auth.auth().signIn(with: accessToken) { (user, error) in
      if error != nil {

        print("Login Failed, \(error!)")
        self.errorAlert.configureContent(title: "Alert!", body: "\(error?.localizedDescription as String!)")
        self.presentAlert()

      } else {
        let userRef = Api.User.usersRef.document((user?.uid)!)
        
        userRef.getDocument { (document, error) in
          if let document = document, document.exists {
            print("User exists.")
            self.sendHome()
          } else {
            print("No user exists.")
            self.signupAlert.configureContent(title: "No Account Yet", body: "Please create an account to continue.")
            self.presentSignupAlert()
          }
        }
      }
    }
  }
  
  @objc func signInWithGoogle() {
    if permission.status == .authorized {
      let shared = GIDSignIn.sharedInstance()
      shared?.delegate = self
      shared?.shouldFetchBasicProfile = true;
      shared?.delegate = self;
      shared?.uiDelegate = self;
      shared?.signIn()
    } else {
      locationPermissions()
    }
  }
  
  func sendToSignUpPreferences(values: [String: AnyObject]) {
    let vc = PreferencesController()
    vc.userInfo = values
    vc.view.layoutIfNeeded()
    present(vc, animated: false, completion: nil)
  }
  
  func sendHome() {
    let vc = MainTabBarController()
    AppDelegate.sharedInstance().window?.rootViewController = vc
    guard let mainTabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
    mainTabBar.dismiss(animated: false) {
      mainTabBar.presentLaunchView(isLoading: true)
    }
  }
  
  @objc func sendToMain() {
    let vc = MainTabBarController()
    AppDelegate.sharedInstance().window?.rootViewController = vc
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
  
  func layoutSubViews() {
    view.addSubview(background)
    background.edges(to: view)
    print("height=",height)
     print("width=",width)
    view.addSubview(container)
    container.width(width * 0.84)
    container.height(height * 0.355)
    container.centerX(to: view)
    container.top(to: view, offset: height * 0.37)
    
    view.addSubview(profilePicTapped)
    profilePicTapped.top(to: view, offset: height * 0.15)
    let logoHeight = height * 0.125
    profilePicTapped.height(logoHeight)
    profilePicTapped.width(logoHeight)
    profilePicTapped.centerX(to: view)
    
    view.addSubview(signUpTapped)
    signUpTapped.top(to: view, offset: height * 0.07)
    signUpTapped.right(to: view, offset: -(width * 0.055))
    let signInWidth = width * 0.15
    signUpTapped.width(signInWidth)
    signUpTapped.height(signInWidth * 0.283)
    
    view.addSubview(forgotPasswordTapped)
    forgotPasswordTapped.topToBottom(of: container, offset: height * 0.12)
    forgotPasswordTapped.left(to: container)
    let forgotWidth = width * 0.32
    forgotPasswordTapped.width(forgotWidth)
    forgotPasswordTapped.height(forgotWidth * 0.065)
    
    view.addSubview(pushToHome)
    pushToHome.centerY(to: forgotPasswordTapped)
    pushToHome.right(to: container)
    let btnSize = width * 0.205
    pushToHome.width(btnSize)
    pushToHome.height(btnSize)
  }
  
  func setUpContainer() {
    container.addSubview(email)
    email.delegate = self
    container.addSubview(password)
    password.delegate = self
    
    view.addSubview(textFields)
    textFields.top(to: container, offset: height * 0.06)
    textFields.width(width * 0.6267)
    textFields.height(height * 0.13)
    textFields.centerX(to: container)
    textFields.stack(fields, axis: .vertical, height: height * 0.05, spacing: height * 0.03)
    
    let widthOrUser = width * 0.12
    view.addSubview(orUser)
    orUser.topToBottom(of: textFields, offset: height * 0.085)
    orUser.width(widthOrUser)
    orUser.height(widthOrUser * 0.0289)
    orUser.left(to: textFields)
    
    let socialSize = width * 0.112
    view.addSubview(socialLogins)
    socialLogins.width(width * 0.264)
    socialLogins.height(socialSize)
    socialLogins.centerY(to: orUser)
    socialLogins.right(to: textFields)
    socialLogins.stack(socials, axis: .horizontal, width: socialSize, spacing: width * 0.04)
  }
  
  // LOAD:
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.isNavigationBarHidden = true
    layoutSubViews()
    setUpContainer()
    
    locationPermissions()
    GIDSignIn.sharedInstance().delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(false)
  }
  
}

extension SignInController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == email {
      email.errorMessage = nil
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == email {
      email.errorMessage = nil
      let emailText = email.text
      if !((email.text?.count)! == 0) && !(AuthTextField.validateEmail(Input: emailText!)) {
        email.errorMessage = "EMAIL IS INVALID"
      }
    }
  }
  
}

extension SignInController: GIDSignInDelegate, GIDSignInUIDelegate {
  
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if let error = error {
      print(error.localizedDescription)
      return
    }

    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                   accessToken: authentication.accessToken)
    Auth.auth().signIn(with: credential) { (user, error) in

      if let error = error {

        print(error)

      } else {

        let userRef = Api.User.usersRef.document((user?.uid)!)
        
        userRef.getDocument { (document, error) in
          if let document = document, document.exists {
            print("User exists.")
            self.sendHome()
          } else {
            print("No user exists.")
            self.signupAlert.configureContent(title: "No Account Yet", body: "Please create an account to continue.")
            self.presentSignupAlert()
          }
        }
      }
    }
  }
  
}
