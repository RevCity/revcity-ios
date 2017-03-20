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
        /* Container view aesthetics */
        tabBarContainerView = UIView(frame: CGRect(x: 0, y: view.frame.height - tabBarHeight, width: view.frame.width, height: tabBarHeight))
        tabBarContainerView.backgroundColor = tabBarColor
        
        // TODO - more setup
        
        view.addSubview(tabBarContainerView)
        
    }
    
    
    /** Setup the tabs **/
    func setupTabs() {
        
        /* Clear just in case */
        tabBarButtons.removeAll()
        
        /* Overall styling info for each tab */
        let tabBarButtonWidth = view.frame.width / CGFloat(numberOfTabs)
        var xOffset: CGFloat = 0.0
        
        /* Make all tabbar buttons */
        for i in 0 ..< numberOfTabs {
            /* Style */
            let tabBarButton = UIButton(frame: CGRect(x: xOffset, y: 0, width: tabBarButtonWidth, height: tabBarHeight))
            tabBarButton.backgroundColor = .clear
            tabBarButton.setImage(selectedBarButtonImages[i], for: .selected)
            tabBarButton.setImage(unSelectedBarButtonImages[i], for: .normal)
            
            /* Add target */
            // TODO - set target
            
            /* Add to view / list */
            tabBarContainerView.addSubview(tabBarButton)
            tabBarButtons.append(tabBarButton)
            
            /* Increment for appropriate spacing */
            xOffset += tabBarButtonWidth
        }
    }
    
    
    /** Automation of the pressing of a button at a particular index **/
    func programmaticallyPressTabBarButton(atIndex index: Int) {
        // TODO
    }
    
    
    
}
