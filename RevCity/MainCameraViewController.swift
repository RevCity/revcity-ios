//
//  MainCameraViewController.swift
//  RevCity
//
//  Created by Brian Rollison on 3/14/17.
//  Copyright © 2017 Placemaker Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

class MainCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    
    // MARK: Camera Outlets
    @IBOutlet weak var cameraPreview: UIView!
    
    
    // MARK: Camera Variables
    
    // On-Screen UI Elements
    private var circleShutter: UIView = UIView(frame: CGRect(x: 135, y: 498, width: 105, height: 105))
    private var progressCircle = CameraProgress(frame: CGRect(x: 130, y: 493, width: 115, height: 115))
    
    // Camera Inputs/Outputs
    private var cameraView: AVCaptureVideoPreviewLayer!
    private var camera: AVCaptureDevice!
    private var cameraInput: AVCaptureDeviceInput!
    private var photoOutput: AVCapturePhotoOutput!
    private var videoOuput: AVCaptureMovieFileOutput? = nil
    private var backgroundRecordingID: UIBackgroundTaskIdentifier? = nil
    private var startingZoom: CGFloat = 1
    private var pinchToZoomGesture: UIPinchGestureRecognizer?
    
    // Camera Background Variables
    private var photoSampleBuffer: CMSampleBuffer?
    private var previewPhotoSampleBuffer: CMSampleBuffer?
    var photoData: Data? = nil
    var outputFileLocation: URL?
    
    override var prefersStatusBarHidden: Bool { return true }
    
    
    // MARK: Camera Constants
    let cameraSession = AVCaptureSession()
    private let cameraPhotoOutput = AVCapturePhotoOutput()
    private let cameraVideoOutput = AVCaptureMovieFileOutput()
    private let cameraStateBar = UIView()
    
    
    
    // MARK: Camera Setup
    
    private func createCamera() {
        cameraSession.beginConfiguration()
        cameraSession.sessionPreset = AVCaptureSessionPresetPhoto
        cameraSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        
        // Add Camera Input
        if let defaultCamera = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
            camera = defaultCamera.first
            do {
                let cameraInput = try AVCaptureDeviceInput(device: camera)
                if cameraSession.canAddInput(cameraInput) {
                    cameraSession.addInput(cameraInput)
                    print("Camera input added to the session")
                }
            } catch { print("Could not add camera input to the camera session") }
        }
        
        // Add Camera View Input
        if let cameraView = AVCaptureVideoPreviewLayer(session: cameraSession) {
            cameraView.frame = cameraPreview.bounds
            cameraView.videoGravity = AVLayerVideoGravityResizeAspectFill
            cameraView.cornerRadius = 12.0
            cameraPreview.layer.addSublayer(cameraView)
            print("Camera view created for the camera session")
        } else { print("Could not create camera preview") }
        
        // Add Photo Output
        if cameraSession.canAddOutput(cameraPhotoOutput) {
            cameraSession.addOutput(cameraPhotoOutput)
            cameraPhotoOutput.isHighResolutionCaptureEnabled = true
            print("Camera output added to the camera session")
        } else {
            print("Could not add camera photo output to the camera session")
            cameraSession.commitConfiguration()
            return
        }
        
        cameraSession.commitConfiguration()
        
        cameraSession.startRunning()
        
        startContinuousFocusExposure()
        
    }
    
    
    // MARK: Camera Button Actions
    
    @IBOutlet var floatingButtons: [UIButton]!
    
    @IBOutlet weak var exitCamera: UIButton!
    @IBAction func exitCamera(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        
        print("User closed camera with exitCamera button")
    }
    
    @IBOutlet weak var flashOff: UIButton!
    @IBAction func flashOff(_ sender: UIButton) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        flashOff.isHidden = true
        flashOn.isHidden = false
        
    }
    
    @IBOutlet weak var flashOn: UIButton!
    @IBAction func flashOn(_ sender: UIButton) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        flashOn.isHidden = true
        flashOff.isHidden = false
    }
    
    @IBOutlet weak var switchCamera: UIButton!
    @IBAction func switchCamera(_ sender: UIButton) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        toggleCameraView()
    }
    
    @IBOutlet weak var loopCamera: UIButton!
    @IBAction func loopCamera(_ sender: UIButton) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        if loopCamera.alpha == 1.0 { print("Loop camera state is already selected"); return }
        else {
            loopCamera.alpha = 1.0
            photoCamera.alpha = 0.5
            videoCamera.alpha = 0.5
            moveCameraStateBar()
            cameraShutter.tintColor = UIColor(red: 1.00, green: 0.80, blue: 0.40, alpha: 1.0)
            print("Loop camera state selected")
            cameraSession.beginConfiguration()
            cameraSession.removeOutput(cameraVideoOutput)
            if cameraSession.canAddOutput(cameraPhotoOutput) {
                cameraSession.addOutput(cameraPhotoOutput)
                toggleAudioInput()
                cameraSession.commitConfiguration()
            } else { print("Camera photo output already selected") }
        }
    }
    
    
    @IBOutlet weak var photoCamera: UIButton!
    @IBAction func photoCamera(_ sender: UIButton) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        if photoCamera.alpha == 1.0 { print("Photo camera state is already selected"); return }
        else {
            loopCamera.alpha = 0.5
            photoCamera.alpha = 1.0
            videoCamera.alpha = 0.5
            moveCameraStateBar()
            cameraShutter.tintColor = UIColor.white
            print("Photo camera state selected")
            cameraSession.beginConfiguration()
            cameraSession.removeOutput(cameraVideoOutput)
            if cameraSession.canAddOutput(cameraPhotoOutput) {
                cameraSession.addOutput(cameraPhotoOutput)
                toggleAudioInput()
                cameraSession.commitConfiguration()
            } else { print("Camera photo output already selected") }
        }
    }
    
    @IBOutlet weak var videoCamera: UIButton!
    @IBAction func videoCamera(_ sender: UIButton) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        if videoCamera.alpha == 1.0 { print("Video camera state is already selected"); return }
        else {
            loopCamera.alpha = 0.5
            photoCamera.alpha = 0.5
            videoCamera.alpha = 1.0
            moveCameraStateBar()
            cameraShutter.tintColor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.0)
            print("Video camera state selected")
            cameraSession.beginConfiguration()
            cameraSession.removeOutput(cameraPhotoOutput)
            if cameraSession.canAddOutput(cameraVideoOutput) {
                cameraSession.addOutput(cameraVideoOutput)
                toggleAudioInput()
                cameraSession.commitConfiguration()
            } else { print("Camera video output already selected") }
        }
    }
    
    @IBOutlet weak var cameraShutter: UIButton!
    @IBAction func cameraShutter(_ sender: UIButton) {
        // Take a Photo
        if photoCamera.alpha == 1 {
            let photoSettings = AVCapturePhotoSettings()
            if flashOff.isHidden == false { photoSettings.flashMode = .off }
            else if flashOff.isHidden == true { photoSettings.flashMode = .on }
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.isAutoStillImageStabilizationEnabled = true
            if photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0 {
                photoSettings.previewPhotoFormat = [ kCVPixelBufferPixelFormatTypeKey as String : photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
            }
            cameraPhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
        
        // Take a Video (video preselected)
        if videoCamera.alpha == 1 {
//            if self.cameraVideoOutput.isRecording { self.cameraVideoOutput.stopRecording() }
//            else {
//                //let videoURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                //let videoFilePath = videoURL.appendingPathComponent("temp")
//                self.cameraVideoOutput.connection(withMediaType: AVMediaTypeVideo).videoOrientation = self.VideoOrientation()
//                self.cameraVideoOutput.maxRecordedDuration = self.maxRecordedDuration()
//                self.cameraVideoOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: self.videoFileLocation()),
//                                                      recordingDelegate: self)
//            }
            progressCircle.animateProgress(duration: 60, fromValue: 0, toValue: 1)
            self.animateRecordingButton()
            if flashOff.isHidden == true { toggleTorchOn() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCameraStateBar()
        
        // Enable Pinch to Zoom Gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        pinchGesture.delegate = cameraView as! UIGestureRecognizerDelegate?
        view.addGestureRecognizer(pinchGesture)
        self.pinchToZoomGesture = pinchGesture
        
        // Enable Toggle Camera by Swipe Gesture
        let cameraSwipe = UISwipeGestureRecognizer(target: self, action: #selector(toggleCameraView))
        cameraSwipe.direction = [.left, .right]
        self.view.addGestureRecognizer(cameraSwipe)
        
        // Initiate Pan Down Gesture for Dismissal
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_ :)))
        panGestureRecognizer.require(toFail: cameraSwipe)
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        // Enable Taptic Feedback
        if let feedbackGenerator: UISelectionFeedbackGenerator? = nil { feedbackGenerator?.prepare() }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        exitCamera.center.y = exitCamera.center.y - self.view.frame.height
        flashOff.center.x = flashOff.center.x - self.view.frame.width
        flashOn.center.x = flashOn.center.x - self.view.frame.width
        switchCamera.center.x = switchCamera.center.x + self.view.frame.width
        loopCamera.center.y = loopCamera.center.y + self.view.frame.height
        photoCamera.center.y = photoCamera.center.y + self.view.frame.height
        videoCamera.center.y = videoCamera.center.y + self.view.frame.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.exitCamera.alpha = 1.0
            self.exitCamera.center.y = self.exitCamera.center.y + self.view.frame.height
            self.flashOn.alpha = 1.0
            self.flashOn.center.x = self.flashOn.center.x + self.view.frame.width
            self.flashOff.alpha = 1.0
            self.flashOff.center.x = self.flashOff.center.x + self.view.frame.width
            self.switchCamera.alpha = 1.0
            self.switchCamera.center.x = self.switchCamera.center.x - self.view.frame.width
            self.loopCamera.alpha = 0.5
            self.loopCamera.center.y = self.loopCamera.center.y - self.view.frame.height
            self.photoCamera.alpha = 1.0
            self.photoCamera.center.y = self.photoCamera.center.y - self.view.frame.height
            self.videoCamera.alpha = 0.5
            self.videoCamera.center.y = self.videoCamera.center.y - self.view.frame.height
            for button in self.floatingButtons {
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
                button.layer.shadowOpacity = 0.75
                button.layer.shadowRadius = 1.0
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide UI Elements Not Immediately Needed
        self.flashOn.isHidden = true
        self.flashOff.isHidden = false
        for button in self.floatingButtons { button.alpha = 0.0 }
        
        createCamera()
        
        // Create UI Elements to Display Immediately
        createShutterBackground()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("Camera capture session ended")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Take Video
    
    private func videoFileLocation() -> String {
        return NSTemporaryDirectory().appending("videoFile.mov")
    }
    
    private func maxRecordedDuration() -> CMTime {
        let seconds: Int64 = 60
        let preferredTimeScale: Int32 = 1
        return CMTimeMake(seconds, preferredTimeScale)
    }
    
    private func animateRecordingButton() {
        // Remove UI Elements (animated)
        UIView.animate(withDuration: 0.3, animations: {
            for button in self.floatingButtons { button.alpha = 0 }
            self.cameraStateBar.alpha = 0
        })
        UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse], animations: { () -> Void in
            self.circleShutter.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            self.progressCircle.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        })
    }
    
    
    
    
    
    // MARK: Camera Helpers
    
    private func moveCameraStateBar() {
        let duration = 0.25
        let delay = 0.0
        let options = UIViewAnimationOptions.curveEaseOut
        let vertical: CGFloat = 664
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            if self.loopCamera.alpha == 1.0 { self.cameraStateBar.center = CGPoint(x: self.loopCamera.center.x, y: vertical) }
            else if self.photoCamera.alpha == 1.0 { self.cameraStateBar.center = CGPoint(x: self.photoCamera.center.x, y: vertical) }
            else if self.videoCamera.alpha == 1.0 { self.cameraStateBar.center = CGPoint(x: self.videoCamera.center.x, y: vertical) }
        }, completion: nil)
        print("New camera state selected")
    }
    
    @objc private func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        view.frame.origin = translation
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: view)
            if velocity.y >= 1500 {
                self.dismiss(animated: true, completion: nil)
                print("Camera capture session dismissed via drag gesture")
            } else { UIView.animate(withDuration: 0.3, animations: { self.view.frame.origin = CGPoint(x: 0, y: 0) }) } }
    }
    
    internal override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first! as UITouch
        let screenSize = cameraPreview.bounds.size
        let focusPoint = CGPoint(x: touchPoint.location(in: cameraPreview).y / screenSize.height, y: 1.0 - touchPoint.location(in: cameraPreview).x / screenSize.width)
        if let cameraTouch = camera {
            do {
                try cameraTouch.lockForConfiguration()
                if cameraTouch.isFocusPointOfInterestSupported {
                    cameraTouch.focusPointOfInterest = focusPoint
                    cameraTouch.focusMode = AVCaptureFocusMode.autoFocus
                }
                if cameraTouch.isExposurePointOfInterestSupported {
                    cameraTouch.exposurePointOfInterest = focusPoint
                    cameraTouch.exposureMode = AVCaptureExposureMode.autoExpose
                }
                cameraTouch.unlockForConfiguration()
                startContinuousFocusExposure()
            } catch { print("Could not implement touch to focus/expose: \(error)") }
        }
    }
    
    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
        let camera: AVCaptureDevice = self.camera
        do {
            try camera.lockForConfiguration()
            switch recognizer.state {
            case .began : self.startingZoom = camera.videoZoomFactor
            case .changed :
                var factor = self.startingZoom * recognizer.scale
                factor = max(1, min(factor, camera.activeFormat.videoMaxZoomFactor))
                camera.videoZoomFactor = factor
            default : break
            }
            camera.unlockForConfiguration()
        } catch { print("Could not handle pinch to zoom gesture: \(error)") }
    }
    
    @objc private func toggleCameraView() {
        cameraSession.beginConfiguration()
        guard let currentCameraInput: AVCaptureInput = cameraSession.inputs.first as? AVCaptureInput else { return }
        cameraSession.removeInput(currentCameraInput)
        var newCamera: AVCaptureDevice! = nil
        if let cameraInput = currentCameraInput as? AVCaptureDeviceInput {
            if (cameraInput.device.position == .back) { newCamera = cameraWithPosition(position: .front) }
            else { newCamera = cameraWithPosition(position: .back) }
        }
        var err: NSError?
        var newCameraInput: AVCaptureDeviceInput!
        do { newCameraInput = try AVCaptureDeviceInput(device: newCamera) }
        catch let err1 as NSError {
            err = err1
            newCameraInput = nil
        }
        if newCameraInput == nil || err != nil { print("Error creating new camera device input: \(err?.localizedDescription)") }
        else { cameraSession.addInput(newCameraInput) }
        cameraSession.commitConfiguration()
        print("User switch camera view")
    }
    
    private func toggleTorchOn() {
        if camera.hasTorch {
            do {
                try camera.lockForConfiguration()
                let torchOn = !camera.isTorchActive
                try camera.setTorchModeOnWithLevel(1.0)
                camera.torchMode = torchOn ? .on : .off
                camera.unlockForConfiguration()
            } catch { print("Error turning on torch for capture") }
        }
    }
    
    private func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        if let cameraDiscovery = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified) {
            for camera in cameraDiscovery.devices { if camera.position == position { return camera }}
        }
        return nil
    }
    
    private func VideoOrientation() -> AVCaptureVideoOrientation {
        var videoOrientation: AVCaptureVideoOrientation!
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        switch orientation {
        case .portrait : videoOrientation = .portrait
        case .landscapeRight : videoOrientation = .landscapeLeft
        case .landscapeLeft : videoOrientation = .landscapeRight
        case .portraitUpsideDown : videoOrientation = .portraitUpsideDown
        default : videoOrientation = .portrait
        }
        return videoOrientation
    }
    
    private func startContinuousFocusExposure() {
        if camera!.isFocusModeSupported(.continuousAutoFocus) {
            do {
                try! camera!.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
        if camera!.isExposureModeSupported(.continuousAutoExposure) {
            do {
                try! camera!.lockForConfiguration()
                camera.exposureMode = .continuousAutoExposure
                camera.unlockForConfiguration()
            }
        }
    }
    
    private func toggleAudioInput() {
        do {
            let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if videoCamera.alpha == 1 {
                if cameraSession.canAddInput(audioInput) {
                    cameraSession.addInput(audioInput)
                    print("Audio added to the camera session")
                }
            }
            if videoCamera.alpha != 1 {
                cameraSession.removeInput(audioInput)
                print("Audio removed from the camera session")
            }
        } catch { print("Could not create an audio device input: \(error)") }
    }
    
    func createShutterBackground() {
        let circleDiameter: Double = 105.0
        let circleRadius: Double = circleDiameter / 2
        circleShutter.layer.cornerRadius = CGFloat(circleRadius)
        circleShutter.backgroundColor = UIColor.clear
        circleShutter.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = circleShutter.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(circleShutter, at: 2)
        circleShutter.addSubview(blurEffectView)
        
        view.insertSubview(progressCircle, belowSubview: circleShutter)
        
    }
    
    private func createCameraStateBar() {
        let barWidth: Double = 75.0
        let barHeight: Double = 4.0
        self.cameraStateBar.frame = CGRect(x: 150, y: 663, width: barWidth, height: barHeight)
        cameraStateBar.roundCorners(corners: [.topLeft, .topRight], radius: 4)
        cameraStateBar.backgroundColor = UIColor.white
        cameraStateBar.layer.shadowColor = UIColor.black.cgColor
        cameraStateBar.layer.shadowOpacity = 0.75
        cameraStateBar.layer.shadowRadius = 1.0
        view.addSubview(cameraStateBar)
    }
    
}

// MARK: Capture Photo Delegate Methods
extension MainCameraViewController: AVCapturePhotoCaptureDelegate {
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let photoDataProvider = CGDataProvider(data: photoData as! CFData)
            let cgImagePhotoRef = CGImage(jpegDataProviderSource: photoDataProvider!, decode: nil, shouldInterpolate: true, intent: .absoluteColorimetric)
            let currentCameraInput: AVCaptureInput = (cameraSession.inputs.first as? AVCaptureInput)!
            if let cameraInput = currentCameraInput as? AVCaptureDeviceInput {
                if (cameraInput.device.position == .back) {
                    let newPhoto = UIImage(cgImage: cgImagePhotoRef!, scale: UIScreen.main.scale, orientation: UIImageOrientation.right)
                    let reviewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReviewVC") as! ReviewViewController
                    reviewVC.captureContent = newPhoto
                    print("Photo captured by back-facing camera, sent to ReviewViewController")
                    DispatchQueue.main.async { self.present(reviewVC, animated: false, completion: nil) }
                }
                if (cameraInput.device.position == .front) {
                    let newPhoto = UIImage(cgImage: cgImagePhotoRef!, scale: UIScreen.main.scale, orientation: UIImageOrientation.leftMirrored)
                    let reviewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReviewVC") as! ReviewViewController
                    reviewVC.captureContent = newPhoto
                    print("Photo captured by front-facing camera, sent to ReviewViewController")
                    DispatchQueue.main.async { self.present(reviewVC, animated: false, completion: nil) }
                }
            }
        }
        else {
            print("Error capturing photo: \(error)")
            return
        }
    }
}

// MARK: Capture Video Delegate Methods
extension MainCameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        return
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("Finished recording: \(outputFileURL)")
        self.outputFileLocation = outputFileURL
        
        // SHOULD RECOGNIZE IF FRONT/BACK CAMERA && INSTANTIATE VIEWREVIEWVC...LIKE A PHOTO!!!
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

// MARK: Time Progress Indicator (Video Capture)
class CameraProgress: UIView {
    var progressLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        let progressPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: 115 / 2, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat((M_PI * 2.0) - M_PI_2), clockwise: true)
        progressLayer = CAShapeLayer()
        progressLayer.path = progressPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.0).cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateProgress(duration: TimeInterval, fromValue: CGFloat, toValue: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        progressLayer.strokeEnd = toValue
        progressLayer.add(animation, forKey: "animateCircle")
    }
}
