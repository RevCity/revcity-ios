//
//  CustomTabBarController.swift
//  RevCity
//
//  Created by Brian Rollison on 3/5/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("the previous tab was index \(selectedIndex)")
        UserDefaults.standard.set(selectedIndex, forKey: "previousTab")
        UserDefaults.standard.synchronize()
        
        if (item.tag == 2) {
            let mainCamera = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainCamera") as! MainCameraViewController
            self.present(mainCamera, animated: true, completion: nil)
            print("Calling main camera from tab bar selection")
        }
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.title == "MainCameraLauncher" {
            performSegue(withIdentifier: "MainCamera", sender: nil)
            print("Opening to main camera from tab bar selection")
            return false
        } else { print("User selected a non-camera tab"); return true }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // make unselected icons black
        self.tabBar.unselectedItemTintColor = UIColor(colorLiteralRed: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
