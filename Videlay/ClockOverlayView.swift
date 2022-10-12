//
//  ClockOverlayView.swift
//  Videlay
//
//  Created by June Kim on 10/9/22.
//

import UIKit
import CircleProgressView

// shows a percentage of a stroked circle
class ClockOverlayView: UIView {
  
  private let whiteCircle = CircleProgressView()
  private let redCircle = CircleProgressView()
  
  // assume portrait only.
  static let outerDiameter = UIScreen.main.bounds.width * 0.8
  
  private var displayLink: CADisplayLink?
  private var startTime = 0.0
  private var animationLength = 1.0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    addCircles()
  }
  
  
  func startDisplayLink() {
    stopDisplayLink() /// make sure to stop a previous running display link
    startTime = CACurrentMediaTime() // reset start time
    
    /// create displayLink and add it to the run-loop
    let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
    displayLink.add(to: .main, forMode: .common)
    self.displayLink = displayLink
  }
  
  @objc func displayLinkDidFire(_ displayLink: CADisplayLink) {
    
    var elapsedTime = CACurrentMediaTime() - startTime
    
    if elapsedTime >= animationLength {
      stopDisplayLink()
      elapsedTime = animationLength /// clamp the elapsed time to the animation length
      redCircle.isHidden = true
    } else {
      /// do your animation logic here
      let portion = elapsedTime / animationLength
      redCircle.progress = portion
      redCircle.isHidden = false
    }
  }
  
  
  func stopDisplayLink() {
    displayLink?.invalidate()
    displayLink = nil
  }
  
  func addCircles() {
    whiteCircle.frame = CGRect(x: 0, y: 0,
                               width: ClockOverlayView.outerDiameter,
                               height: ClockOverlayView.outerDiameter)
    let smallerBy: CGFloat = 0.9
    redCircle.frame = CGRect(x: ClockOverlayView.outerDiameter * (1 - smallerBy) / 2,
                             y: ClockOverlayView.outerDiameter * (1 - smallerBy) / 2,
                               width: ClockOverlayView.outerDiameter * smallerBy,
                               height: ClockOverlayView.outerDiameter * smallerBy)
    
    whiteCircle.backgroundColor = .clear
    whiteCircle.trackBackgroundColor = .clear
    whiteCircle.trackFillColor = .white.withAlphaComponent(0.3)
    whiteCircle.centerFillColor = .clear
    whiteCircle.clockwise = false
    whiteCircle.progress = 1
    whiteCircle.isHidden = true

    redCircle.backgroundColor = .clear
    redCircle.trackBackgroundColor = .clear
    redCircle.trackFillColor = .systemRed.withAlphaComponent(0.7)
    redCircle.centerFillColor = .clear
    redCircle.clockwise = true
    
    addSubview(whiteCircle)
    addSubview(redCircle)
    
  }
  
  func setInterval(progress: CGFloat) {
    whiteCircle.progress = progress
  }
  
  func animateRedCircle(duration: CGFloat) {
    animationLength = duration
    startDisplayLink()
    whiteCircle.isHidden = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}
