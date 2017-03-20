//
//  TabBarController.swift
//  RevCity
//
//  Created by Joseph Antonakakis on 3/20/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import UIKit

/** Tab bar at the bottom of the app, driving transitions between views **/
class TabBarController: UIViewController {
    
    /* Overall fields */
    var numberOfTabs: Int = 0
    var tabBarContainerView: UIView = UIView()
    var tabBarButtons: [UIButton] = [UIButton]()
    var transparentBarEnabled: Bool = false
    var tabBarButtonFireEvent: UIControlEvents = .touchDown
    var tabBarIsHidden: Bool = false
    var preselectedTabIndex = 0
    var tabBarHeight: CGFloat {
        return view.frame.height * 0.1
    }
    
    
    /* Aesthetics */
    var selectedBarButtonImages: [Int:UIImage] = [Int:UIImage]()
    var unSelectedBarButtonImages: [Int:UIImage] = [Int:UIImage]()
    var tabBarColor: UIColor = .white {
        didSet {
            tabBarContainerView.backgroundColor = tabBarColor
        }
    }
    
    
    /* View logistics */
    var currentlyPresentedViewController: UIViewController?
    var onTabBarButtonPress: [Int: () -> ()] = [Int: () -> ()]()
    
    
    /** Required **/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup */
        view.backgroundColor = .white
        createTabBarContainerView()
        setupTabs()

    }

    
    /** Required **/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /** Create the container for the tab bar **/
    func createTabBarContainerView() {
        // TODO
    }
    
    
    /** Setup the tabs **/
    func setupTabs() {
        // TODO
    }
    
    
    /** Automation of the pressing of a button at a particular index **/
    func programmaticallyPressTabBarButton(atIndex index: Int) {
        // TODO 
    }
    
    
    
}
