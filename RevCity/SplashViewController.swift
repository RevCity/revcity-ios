//
//  SplashViewController.swift
//  RevCity
//
//  Created by Daniel Li on 3/26/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let titleLabel = UILabel()
        titleLabel.text = "RevCity"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        titleLabel.center = view.center
        view.addSubview(titleLabel)
        
        setupButtons()
    }
    
    func setupButtons() {
        
        let margin: CGFloat = 16.0
        let height: CGFloat = 44.0
        let width: CGFloat = (view.frame.width - margin * 3) / 2
        
        let signUpButton = UIButton(frame: CGRect(x: margin, y: view.frame.height - margin - height, width: width, height: height))
        signUpButton.backgroundColor = .white
        signUpButton.layer.cornerRadius = 2.0
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.addTarget(self, action: #selector(tappedSignUp), for: .touchUpInside)
        view.addSubview(signUpButton)
        
        let signInButton = UIButton(frame: CGRect(x: margin * 2 + width, y: view.frame.height - margin - height, width: width, height: height))
        signInButton.layer.borderColor = UIColor.white.cgColor
        signInButton.layer.cornerRadius = 2.0
        signInButton.setTitle("Log in", for: .normal)
        signInButton.addTarget(self, action: #selector(tappedSignIn), for: .touchUpInside)
        view.addSubview(signInButton)
    }
    
    func tappedSignUp() {
        let loginViewController = LoginViewController()
        loginViewController.loginType = .signUp
        present(loginViewController, animated: true, completion: nil)
    }
    
    func tappedSignIn() {
        let loginViewController = LoginViewController()
        loginViewController.loginType = .signIn
        present(loginViewController, animated: true, completion: nil)
    }
    


}
