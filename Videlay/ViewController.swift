//
//  ViewController.swift
//  Videlay
//
//  Created by June Kim on 10/2/22.
//

import UIKit
import NextLevel
import AVFoundation
import Crisp
import PhotosUI


enum TimelapseState {
  case unknown
  case standby
  case activeInLoop
  case idleInLoop
}

class ViewController: UIViewController {
  
  let spinner = UIActivityIndicatorView(style: .large)
  var previewView = UIView()
  let minimumZoom: CGFloat = 0.5
  let maximumZoom: CGFloat = 5.0
  var lastZoomFactor: CGFloat = 1.0
  let controlsContainer = UIView()
  let recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
  
  let runloop = ClockRunloop()
  let clockOverlay = ClockOverlayView()
  let timerLabel = UILabel()
  
  var configButton: UIButton!
  var chatButton: UIButton!
  var exportButton: UIButton!

  var cycleCounter = 0
  
  var timelapseState: TimelapseState = .unknown {
    didSet {
      print(timelapseState)
      renderTimelapseState()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    view.backgroundColor = .darkGray
    
    setupCameraPreview()
    configureCaptureSession()
    addButtons()
    addClockOverlay()
    addSpinner()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tryStartingRecordingSession()
    configureRunloop()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
//    showConfigVC()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NextLevel.shared.stop()
  }
  
  func setupCameraPreview() {
    let screenBounds = UIScreen.main.bounds
    previewView.frame = screenBounds
    previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    NextLevel.shared.previewLayer.frame = previewView.bounds
    previewView.layer.addSublayer(NextLevel.shared.previewLayer)
    self.view.addSubview(previewView)

  }

  func addSpinner() {
    view.addSubview(spinner)
    spinner.startAnimating()
    spinner.centerXInParent()
    spinner.centerYInParent(offset: -30)
  }
  
  func addButtons() {
    view.addSubview(controlsContainer)
    controlsContainer.fillParent()
    let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch(_:)))
    controlsContainer.addGestureRecognizer(pinchRecognizer)

    addChatButton()
    addRecordButton()
    addConfigButton()
    addTimerLabel()
    addExportButton()
  }
  
  func addChatButton() {
    var config = UIButton.Configuration.filled()
    config.baseForegroundColor = .white
    config.baseBackgroundColor = .black.withAlphaComponent(0.3)
    config.cornerStyle = .large
    config.buttonSize = .large
    config.image = UIImage(systemName: "ellipsis.bubble.fill")!
    
    let button = UIButton(configuration: config, primaryAction: UIAction() { _ in
      self.showChatVCWithDialog()
    })
    controlsContainer.addSubview(button)
    button.pinTrailingToParent(margin: 8)
    button.pinTopToParent(margin: 8, insideSafeArea: true)
    button.isEnabled = false

    chatButton = button
  }
  
  func addRecordButton() {
    controlsContainer.addSubview(recordButton)
    recordButton.pinBottomToParent(margin: 15, insideSafeArea: true)
    recordButton.centerXInParent()
    recordButton.setSquare(constant: recordButton.defaultSize)
    recordButton.backgroundColor = .gray
    
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(tappedRecordButton))
    recordButton.addGestureRecognizer(recognizer)
  }
  
  func addConfigButton() {
    var config = UIButton.Configuration.filled()
    config.baseForegroundColor = .white
    config.baseBackgroundColor = .black.withAlphaComponent(0.3)
    config.cornerStyle = .large
    config.buttonSize = .large
    config.image = UIImage(systemName: "gearshape.fill")!
    
    let button = UIButton(configuration: config, primaryAction: UIAction() { _ in
      self.showConfigVC()
    })
    controlsContainer.addSubview(button)
    button.pinLeadingToParent(margin: 8)
    button.pinTopToParent(margin: 8, insideSafeArea: true)
    button.isEnabled = false
    self.configButton = button
  }
  
  func addClockOverlay() {
    view.addSubview(clockOverlay)
    clockOverlay.setSquare(constant: ClockOverlayView.outerDiameter)
    clockOverlay.centerXInParent()
    clockOverlay.centerYInParent()
    clockOverlay.isUserInteractionEnabled = false
  }
  
  func configureRunloop() {
    runloop.loopSeconds = Int(ConfigViewController.configuredIntervalMinutes()) * 60
    runloop.delegate = self
  }
  
  func showChatVCWithDialog() {
    let alertController = UIAlertController(title: "Chat with the developer", message: "I would love to know about your experience with Shortn. Please help make this app better with feedback. I get notifications straight to my iPhone!", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Chat", style: .default, handler: { _ in
      self.present(ChatViewController(), animated: true)
    }))
    alertController.addAction(UIAlertAction(title: "Not now", style: .cancel))
    present(alertController, animated: true)
  }
  
  func showConfigVC() {
    let configVC = ConfigViewController()
    configVC.delegate = self
    present(configVC, animated: true)
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
  
  func addTimerLabel() {
    view.addSubview(timerLabel)
    timerLabel.pinTopToParent(margin: 8, insideSafeArea: true)
    timerLabel.set(height: 50)
    timerLabel.set(width: 200)
    timerLabel.centerXInParent()
    timerLabel.timeFormat()
  }
  
  func addExportButton() {
    var exportConfig = UIButton.Configuration.plain()
    exportConfig.image = UIImage(named: "photos-app-icon")
    exportButton = UIButton(configuration: exportConfig, primaryAction: UIAction() { _ in
      self.export()
    })
    view.addSubview(exportButton)
    exportButton.pinBottomToParent(margin: 8, insideSafeArea: true)
    exportButton.pinTrailingToParent(margin: 8)
    exportButton.setImageScale(to: 0.8)
    exportButton.alpha = 0.3
  }
  
  func tryStartingRecordingSession() {
    requestPermissions() { [weak self] granted in
      guard let self = self else { return }
      guard granted else {
        self.showPermissionRequiredAlert()
        return
      }
      DispatchQueue.global().async {
        do {
          try NextLevel.shared.changeCaptureDeviceIfAvailable(captureDevice: .tripleCamera)
        } catch {
          do {
            try NextLevel.shared.changeCaptureDeviceIfAvailable(captureDevice: .duoCamera)
          } catch {
            do {
              try NextLevel.shared.changeCaptureDeviceIfAvailable(captureDevice: .dualWideCamera)
            } catch {
              print("did not change capture device")
            }
          }
        }
        do {
          NextLevel.shared.automaticallyUpdatesDeviceOrientation = true
          try NextLevel.shared.start()
          DispatchQueue.main.async {
            self.timelapseState = .standby
          }
        } catch {
          print(error)
        }
      }
    }

  }
  
  func requestPermissions(_ completion: @escaping (Bool) -> ()) {
    var audioGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    var videoGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    if audioGranted && videoGranted {
      completion(true)
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
      completion(audioGranted && videoGranted)
    }
  }
  
  func showPermissionRequiredAlert() {
    let alert = UIAlertController(title: "Need camera & microphone permission", message: "Go to the settings app to enable camera permissions for this app", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    present(alert, animated: false)
  }
  
  func renderTimelapseState() {
    let intervalProgress: CGFloat = CGFloat(runloop.secondsRemaining) / CGFloat(ConfigViewController.configuredIntervalMinutes() * 60)
    
    clockOverlay.setInterval(progress: intervalProgress)
    
    switch timelapseState {
    case .unknown:
      recordButton.backgroundColor = .gray
      configButton.isEnabled = false
      chatButton.isEnabled = true
      exportButton.isEnabled = false
    case .standby:
      spinner.stopAnimating()
      recordButton.backgroundColor = .systemRed
      configButton.isEnabled = cycleCounter == 0
      chatButton.isEnabled = true
      exportButton.isEnabled = cycleCounter > 0
    case .activeInLoop:
      recordButton.backgroundColor = .systemPink.withAlphaComponent(0.5)
      configButton.isEnabled = false
      chatButton.isEnabled = false
      exportButton.isEnabled = false
    case .idleInLoop:
      recordButton.backgroundColor = .systemPink
      configButton.isEnabled = false
      chatButton.isEnabled = false
      exportButton.isEnabled = false
    }
    
    exportButton.alpha = exportButton.isEnabled ? 1 : 0.3
    
    let secondsText = String(format: "%.1f", Float(cycleCounter) * ConfigViewController.configuredDurationSeconds())
    let minutesText = String(format: "%d", cycleCounter * Int(ConfigViewController.configuredIntervalMinutes()))
    timerLabel.text = secondsText + "s / " + minutesText + "m"
  }
  
  @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
    // Return zoom value between the minimum and maximum zoom values
    func minMaxZoom(_ factor: CGFloat) -> CGFloat {
      return min(max(factor, minimumZoom), maximumZoom)
    }
    
    let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
    print(newScaleFactor)
    switch pinch.state {
    case .began: fallthrough
    case .changed:
      NextLevel.shared.videoZoomFactor = Float(newScaleFactor)
    case .ended:
      lastZoomFactor = minMaxZoom(newScaleFactor)
      NextLevel.shared.videoZoomFactor = Float(lastZoomFactor)
    default: break
    }
  }
  
  @objc func tappedRecordButton() {
    switch timelapseState {
    case .unknown:
      assert(false)
    case .standby:
      runloop.start()
      recordSegment()
      timelapseState = .activeInLoop
      UIApplication.shared.isIdleTimerDisabled = true

    case .activeInLoop:
      print("do nothing")
    case .idleInLoop:
      runloop.stop()
      timelapseState = .standby
      UIApplication.shared.isIdleTimerDisabled = false

    }
  }
  
  func recordSegment() {
    cycleCounter += 1
    NextLevel.shared.record()
    let duration = TimeInterval(ConfigViewController.configuredDurationSeconds())
    Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] timer in
      guard let self = self else { return }
      NextLevel.shared.pause()
      self.timelapseState = .idleInLoop
    }
    clockOverlay.animateRedCircle(duration: duration)
  }
  
  func export() {
    print("export")
    guard let session = NextLevel.shared.session else { return }
    session.mergeClips(usingPreset: AVAssetExportPresetHighestQuality, completionHandler: { (url: URL?, error: Error?) in
      if let url = url {
        self.saveVideoToAlbum(url) { [weak self] err in
          guard let self = self else { return }
          guard err == nil else {
            self.showExportAlert()
            return
          }
          self.showPostSaveAlert()
        }
        self.reset()
      } else if let _ = error {
        self.showExportAlert()
      }
    })
  }
  
  func saveVideoToAlbum(_ outputURL: URL, _ completion: @escaping (Error?) -> ()) {
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetCreationRequest.forAsset()
      request.addResource(with: .video, fileURL: outputURL, options: nil)
    }) { (result, error) in
      DispatchQueue.main.async {
        if let error = error {
          print(error.localizedDescription)
        }
        completion(error)
      }
    }
  }
  
  func reset() {
    cycleCounter = 0
    runloop.stop()
    timelapseState = .standby
    if let session = NextLevel.shared.session {
      session.removeAllClips()
    }
  }

  func showExportAlert() {
    let alertController = UIAlertController(title: "Export failed", message: "I'm not quite sure why but it didn't work for some reason. Maybe you can tell me in the chat?", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
      self.reset()
    }))
    present(alertController, animated: true)
  }
  
  func showPostSaveAlert() {
    let alertController = UIAlertController(title: "Video saved", message: "Go to your photos app to watch the video", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
    present(alertController, animated: true)
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

extension ViewController: ClockRunloopDelegate {
  func clockDidCycleLoop() {
    timelapseState = .activeInLoop
    recordSegment()
  }
  
  func clockDidProgressLoop() {
    renderTimelapseState()
  }
}

extension ViewController: ConfigViewControllerDelegate {
  func configVCDidChangeConfig() {
    runloop.loopSeconds = Int(ConfigViewController.configuredIntervalMinutes()) * 60
    renderTimelapseState()
  }
}
