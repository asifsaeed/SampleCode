//
//  ForgotPasswordController.swift
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

class ForgotPasswordController: UIViewController {
  
  // CONSTANTS:
  
  // VIEWS:
  
  let backTapped: UIButton = {
    let getStarted = UIButton()
    getStarted.setImage(#imageLiteral(resourceName: "Back"), for: .normal)
    getStarted.imageView?.contentMode = .scaleAspectFill
    getStarted.addTarget(self, action: #selector(sendToSignIn), for: .touchUpInside)
    return getStarted
  }()
  
  let profilePicTapped: UIImageView = {
    let getStarted = UIImageView()
    getStarted.image = #imageLiteral(resourceName: "ReperioLogo")
    getStarted.contentMode = .scaleAspectFill
    return getStarted
  }()
  
  let pushToLogin: UIButton = {
    let getStarted = UIButton()
    getStarted.setImage(#imageLiteral(resourceName: "LoginPressed"), for: .normal)
    getStarted.imageView?.contentMode = .scaleAspectFit
    getStarted.addTarget(self, action: #selector(processForgotPassword), for: .touchUpInside)
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
  
  let labelForgot: UIImageView = {
    let labelForgot = UIImageView()
    labelForgot.image = #imageLiteral(resourceName: "ForgotPasswordLabel")
    labelForgot.contentMode = .scaleAspectFill
    return labelForgot
  }()
  
  let email: AuthTextField = {
    let email = AuthTextField(placeholder: "EMAIL", type: UIKeyboardType.emailAddress)
    email.textContentType = UITextContentType.emailAddress
    email.autocapitalizationType = .none
    return email
  }()
  
  let emailSent: MessageView = {
    let success = MessageView.viewFromNib(layout: .cardView)
    success.configureTheme(.success)
    success.configureBackgroundView(width: App.width * 0.84)
    success.backgroundView.backgroundColor = App.blue
    success.configureDropShadow()
    success.configureContent(title: "Email Sent!", body: "Check your email for password reset instructions.")
    success.button?.setTitle("OK", for: .normal)
    success.button?.tintColor = App.blue
    success.button?.addTarget(self, action: #selector(hideEmailSent), for: .touchUpInside)
    return success
  }()
  
  // FUNCTIONS:
  
  @objc func sendToSignIn() {
    let vc = SignInController()
    vc.view.layoutIfNeeded()
    self.dismiss(animated: false, completion: nil)
    //    present(vc, animated: false, completion: nil)
  }
  
  @objc func processForgotPassword() {
    if (email.text == "") {
      
      email.errorMessage = "ENTER EMAIL"
      
    } else {
      
      Auth.auth().fetchProviders(forEmail: (email.text)!) { (authMethods, error) in
        if error == nil {
          if authMethods != nil {
            Auth.auth().sendPasswordReset(withEmail: (self.email.text)!) { error in
              if error != nil {
                // Error - Unidentified Email
                self.email.errorMessage = "UNIDENTIFIED EMAIL"
              } else {
                // Success - Sent recovery email
                self.presentEmailSent()
              }
              
            }
          } else {
            self.email.errorMessage = "UNIDENTIFIED EMAIL"
          }
        }
      }
    }
  }
  
  @objc func hideEmailSent() {
    SwiftMessages.hide()
  }
  
  func presentEmailSent() {
    var successConfig = SwiftMessages.defaultConfig
    successConfig.presentationStyle = .center
    successConfig.duration = .forever
    successConfig.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
    successConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
    emailSent.layoutIfNeeded()
    SwiftMessages.show(config: successConfig, view: emailSent)
  }
  
  func layoutSubViews() {
    view.addSubview(background)
    background.edges(to: view)
    
    view.addSubview(container)
    container.width(App.width * 0.84)
    container.height(App.height * 0.305)
    container.centerX(to: view)
    container.top(to: view, offset: App.height * 0.40)
    
    let logoHeight = App.height * 0.125
    view.addSubview(profilePicTapped)
    profilePicTapped.top(to: view, offset: App.height * 0.15)
    profilePicTapped.height(logoHeight)
    profilePicTapped.width(logoHeight)
    profilePicTapped.centerX(to: view)
    
    let signInWidth = App.width * 0.1
    view.addSubview(backTapped)
    backTapped.top(to: view, offset: App.height * 0.07)
    backTapped.left(to: view, offset: App.width * 0.055)
    backTapped.width(signInWidth)
    backTapped.height(signInWidth)
    
    let btnSize = App.width * 0.205
    view.addSubview(pushToLogin)
    pushToLogin.topToBottom(of: container, offset: App.height * 0.09)
    pushToLogin.right(to: container)
    pushToLogin.width(btnSize)
    pushToLogin.height(btnSize)
  }
  
  func setUpContainer() {
    let widthForgot = App.width * 0.6267
    container.addSubview(labelForgot)
    labelForgot.top(to: container, offset: App.height * 0.1)
    labelForgot.width(widthForgot)
    labelForgot.height(widthForgot * 0.033)
    labelForgot.centerX(to: container)
    
    container.addSubview(email)
    email.delegate = self
    email.topToBottom(of: labelForgot, offset: App.height * 0.08)
    email.width(widthForgot)
    email.height(App.height * 0.045)
    email.centerX(to: container)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.isNavigationBarHidden = true
    layoutSubViews()
    setUpContainer()
  }
  
}

extension ForgotPasswordController: UITextFieldDelegate {
  
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
