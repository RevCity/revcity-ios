//
//  ReviewViewController.swift
//  RevCity
//
//  Created by Brian Rollison on 3/5/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import UIKit
import QuartzCore
import CoreImage

class ReviewViewController: UIViewController {
    
    var captureContent: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var blurImageResult: UIImageView!
    
    // MARK: On-Screen UI Effects
    // Drop Shadows
    @IBOutlet var reviewButtons: [UIButton]!
    private func buttonShadows() {
        for button in reviewButtons {
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            button.layer.shadowOpacity = 0.75
            button.layer.shadowRadius = 1.0
        }
    }
    
    
    // Enable Haptic Feedback for UI Interaction
    private func tapticFeedback() {
        if let feedbackGenerator: UISelectionFeedbackGenerator? = nil {
            feedbackGenerator?.prepare()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        if let availableImage = captureContent {
            imageView.image = availableImage
            imageView.layer.cornerRadius = 12.0
            imageView.clipsToBounds = true
        }
        tapticFeedback()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissBlur()
        blurView.alpha = 0
        blurImageResult.alpha = 0
        buttonShadows()
    }
    
    @IBOutlet weak var returnCamera: UIButton!
    @IBAction func goBack(_ sender: UIButton) {
        // Activate Haptic Feedback (iPhone7/7+)
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveLinear , animations: {
            self.returnCamera.alpha = 0
            self.blurView.alpha = 1.0
        }, completion: { (finished) -> Void in self.dismiss(animated: false, completion: nil)})
    }
    
    @IBOutlet weak var addText: UIButton!
    @IBAction func openAddText(_ sender: UIButton) {
    }
    
    @IBOutlet weak var drawBrush: UIButton!
    @IBAction func openDrawBrush(_ sender: UIButton) {
    }
    
    @IBOutlet weak var addTags: UIButton!
    @IBAction func openTags(_ sender: UIButton) {
    }

    
    @IBOutlet weak var goPost: UIButton!
    @IBAction func goPostAction(_ sender: UIButton) {
    }
    
    
    private func dismissBlur() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurView.addSubview(blurEffectView)
    }
    
    private func createLocationBackground() {
        let bubbleWidth = 260
        let bubbleHeight = 49
        let cornerRadius = bubbleHeight / 2
        let bubbleFrame: UIView = UIView(frame: CGRect(x: 25, y: 593, width: bubbleWidth, height: bubbleHeight))
        bubbleFrame.layer.cornerRadius = CGFloat(cornerRadius)
        bubbleFrame.backgroundColor = UIColor.white
        bubbleFrame.clipsToBounds = true
        bubbleFrame.layer.shadowColor = UIColor.black.cgColor
        bubbleFrame.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        bubbleFrame.layer.shadowOpacity = 0.75
        bubbleFrame.layer.shadowRadius = 1.0
        bubbleFrame.layer.shadowPath = UIBezierPath(rect: bubbleFrame.bounds).cgPath
        view.insertSubview(bubbleFrame, aboveSubview: imageView)
    }
    
    private func createGoPostBackground() {
        let circleDiameter: Double = 49
        let circleRadius: Double = circleDiameter / 2
        let circleFrame: UIView = UIView(frame: CGRect(x: 301, y: 593, width: circleDiameter, height: circleDiameter))
        circleFrame.layer.cornerRadius = CGFloat(circleRadius)
        circleFrame.backgroundColor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.0)
        circleFrame.clipsToBounds = true
        circleFrame.layer.shadowColor = UIColor.black.cgColor
        circleFrame.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        circleFrame.layer.shadowOpacity = 0.75
        circleFrame.layer.shadowRadius = 1.0
        circleFrame.layer.shadowPath = UIBezierPath(rect: circleFrame.bounds).cgPath
        view.insertSubview(circleFrame, aboveSubview: imageView)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
