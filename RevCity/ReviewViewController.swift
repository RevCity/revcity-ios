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
    
    
    private func dismissBlur() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurView.addSubview(blurEffectView)
    }
    
    private func createGuassianBlurDismissImage() {
        let screenShot = UIApplication.shared.keyWindow?.layer
        UIGraphicsBeginImageContext(view.frame.size)
        screenShot!.render(in: UIGraphicsGetCurrentContext()!)
        let copiedPhoto = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let blurRadius = 5
        let ciImage: CIImage = CIImage(cgImage: copiedPhoto as! CGImage)
        let filter: CIFilter = CIFilter(name: "CIGaussianBlur")!
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        let ciContext = CIContext(options: nil)
        let result = filter.value(forKey: kCIOutputImageKey) as! CIImage!
        let cgImage = ciContext.createCGImage(result!, from: view.frame)
        let finalImage = UIImage(cgImage: cgImage!)
        self.blurImageResult.image = finalImage
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
