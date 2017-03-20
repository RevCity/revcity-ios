//
//  LoginViewController.swift
//  RevCity
//
//  Created by Joseph Antonakakis on 3/19/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

/* View presented when a user is not logged in */
class LoginViewController: UIViewController {
    
    /** Required **/
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutSubviews()
        
        if let accessToken = AccessToken.current {
            print(" We are logged in with access token \(accessToken)")
        }
    }
    
    
    /** Required **/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /** Layout the subviews / add selectors as necessary **/
    func layoutSubviews() {
        
        /* Facebook Login Button */
        let loginButton = UIButton(type: .custom)
        loginButton.backgroundColor = UIColor.facebookBlue
        loginButton.frame = CGRect(x: 0, y: 0, width: 300, height: 40)
        loginButton.center = view.center
        loginButton.setTitle("Login to RevCity with Facebook", for: .normal)
        loginButton.addTarget(self, action: #selector(self.fbLoginButtonClicked), for: .touchUpInside)
        
        /* Add subviews */
        view.addSubview(loginButton)
    }
    
    
    /** Facebook Login button clicked -> react accordingly **/
    func fbLoginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email], viewController: self) { (loginResult) in
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
