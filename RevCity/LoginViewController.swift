//
//  LoginViewController.swift
//  RevCity
//
//  Created by Joseph Antonakakis on 3/19/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    enum LoginType {
        case signUp
        case signIn
    }
    
    var loginType: LoginType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCloseButton()
        setupForm()
        
        if let accessToken = AccessToken.current {
            print(" We are logged in with Facebook access token \(accessToken)")
        }
        
    }
    
    func setupCloseButton() {
        let margin: CGFloat = 16.0
        let size: CGFloat = 44.0
        
        let closeButton = UIButton(frame: CGRect(x: margin, y: margin, width: size, height: size))
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    /** Layout the subviews / add selectors as necessary **/
    func setupForm() {
        
        let margin: CGFloat = 44.0
        let height: CGFloat = 44.0
        let buttonMargin: CGFloat = 8.0
        
        let form = UIView()
        form.backgroundColor = .clear
        
        let googleLoginButton = GIDSignInButton(frame: CGRect(x: margin, y: 0.0, width: view.frame.width - (margin * 2), height: height))
        googleLoginButton.style = .wide
        form.addSubview(googleLoginButton)
        
        let facebookLoginButton = UIButton(frame: CGRect(x: margin, y: googleLoginButton.frame.maxY + buttonMargin, width: view.frame.width - (margin * 2), height: height))
        facebookLoginButton.backgroundColor = .facebookBlue
        facebookLoginButton.setTitle("Login to RevCity with Facebook", for: .normal)
        facebookLoginButton.addTarget(self, action: #selector(tappedFacebookLogin), for: .touchUpInside)
        form.addSubview(facebookLoginButton)
        
        form.sizeToFit()
        form.center = view.center
        view.addSubview(form)
    }
    
    func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    /** Facebook Login button clicked -> react accordingly **/
    func tappedFacebookLogin() {
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login")
            case .success( _,  _,  _):
                self.successfulFBLogin()
            }
        }
        
    }
    
    
    /** Handle state-changes resulting from successful FB login **/
    func successfulFBLogin() {
        print("Logged in!")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.didFinishAuthenticatingUser() // Flag we need to transition views
        // TODO - more things involving application state
    }
    
}
