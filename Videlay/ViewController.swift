//
//  ViewController.swift
//  Videlay
//
//  Created by June Kim on 10/2/22.
//

import UIKit
import NextLevel
import AVFoundation

class ViewController: UIViewController {
  
  var previewView = UIView()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    view.backgroundColor = .cyan
    
    setupCameraPreview()
    configureCaptureSession()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tryStartingRecordingSession()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NextLevel.shared.stop()
  }
  
  func setupCameraPreview() {
    let screenBounds = UIScreen.main.bounds
    previewView.frame = screenBounds
    previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    previewView.backgroundColor = UIColor.black
    NextLevel.shared.previewLayer.frame = previewView.bounds
    previewView.layer.addSublayer(NextLevel.shared.previewLayer)
    self.view.addSubview(previewView)
  }

  func configureCaptureSession() {
    NextLevel.shared.delegate = self
    NextLevel.shared.deviceDelegate = self
    NextLevel.shared.videoDelegate = self
    
    // modify .videoConfiguration, .audioConfiguration, .photoConfiguration properties
    // Compression, resolution, and maximum recording time options are available
    NextLevel.shared.videoConfiguration.maximumCaptureDuration = CMTime(seconds: 5, preferredTimescale: 600)
    NextLevel.shared.audioConfiguration.bitRate = 44000
  }
  
  func tryStartingRecordingSession() {
    guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized,
          AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else {
      requestPermissions()
      return
    }
    do {
      try NextLevel.shared.start()
    } catch {
      print(error)
    }
  }
  
  func requestPermissions() {
    var audioGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    var videoGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    if audioGranted && videoGranted {
      self.tryStartingRecordingSession()
      return
    }
    let group = DispatchGroup()
    if !audioGranted {
      group.enter()
      AVCaptureDevice.requestAccess(for: .audio){ granted in
        audioGranted = granted
        group.leave()
      }
    }
    if !videoGranted {
      group.enter()
      AVCaptureDevice.requestAccess(for: .video) { granted in
        videoGranted = granted
        group.leave()
      }
    }
    group.notify(queue: .main) {
      self.requestPermissions()
    }
  }
  
  func showPermissionRequiredAlert() {
    let alert = UIAlertController(title: "Need camera & microphone permission", message: "Go to the settings app to enable camera permissions for this app", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    present(alert, animated: false)
  }
}

extension ViewController: NextLevelDelegate, NextLevelDeviceDelegate, NextLevelVideoDelegate {
  func nextLevel(_ nextLevel: NextLevel, didUpdateVideoConfiguration videoConfiguration: NextLevelVideoConfiguration) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didUpdateAudioConfiguration audioConfiguration: NextLevelAudioConfiguration) {
    
  }
  
  func nextLevelSessionWillStart(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelSessionDidStart(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelSessionDidStop(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelSessionWasInterrupted(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelSessionInterruptionEnded(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelCaptureModeWillChange(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelCaptureModeDidChange(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDevice.Format) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didChangeLensPosition lensPosition: Float) {
    
  }
  
  func nextLevelWillStartFocus(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDidStopFocus(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didUpdateVideoZoomFactor videoZoomFactor: Float) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, willProcessRawVideoSampleBuffer sampleBuffer: CMSampleBuffer, onQueue queue: DispatchQueue) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, renderToCustomContextWithImageBuffer imageBuffer: CVPixelBuffer, onQueue queue: DispatchQueue) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, willProcessFrame frame: AnyObject, timestamp: TimeInterval, onQueue queue: DispatchQueue) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didSetupVideoInSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didSetupAudioInSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didAppendVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didSkipVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didAppendVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didSkipVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didAppendAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didSkipAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didCompleteSession session: NextLevelSession) {
    
  }
  
  func nextLevel(_ nextLevel: NextLevel, didCompletePhotoCaptureFromVideoFrame photoDict: [String : Any]?) {
    
  }
  
  
}
