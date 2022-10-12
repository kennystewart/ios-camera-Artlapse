//
//  ClockRunloop.swift
//  Videlay
//
//  Created by June Kim on 10/9/22.
//

import Foundation
import UIKit

protocol ClockRunloopDelegate: AnyObject {
  func clockDidProgressLoop()
  func clockDidCycleLoop()
}

enum RunloopState {
  case uninitialized
  case standby
  case running
  case paused
}
// can start, pause, stop in one-second increments
// loopSeconds may change
class ClockRunloop {
  var loopSeconds: Int = -1 {
    didSet {
      if loopSeconds > oldValue {
        // increase secondsRemaining.
        secondsRemaining += loopSeconds - oldValue
      } else if loopSeconds < oldValue {
        // decrease secondsRemaining if loopSeconds decreases to less than current seconds remaining.
        secondsRemaining = max(1, min(secondsRemaining, loopSeconds))
      }
      if loopSeconds > 0, state == .uninitialized {
        state = .standby
      }
    }
  }
  weak var delegate: ClockRunloopDelegate?
  
  var secondsRemaining: Int = 0
  var miniTimer: Timer?
  
  var state: RunloopState = .uninitialized
  
  func start() {
    assert(loopSeconds > 0)
    secondsRemaining = loopSeconds
    miniTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
      guard let self = self else { return }
      // decrement secondsRemaining if possible
      if self.secondsRemaining > 0,
         UIApplication.shared.applicationState == .active {
        self.secondsRemaining -= 1
        self.delegate?.clockDidProgressLoop()
      } else if self.secondsRemaining == 0 {
        self.delegate?.clockDidCycleLoop()
        self.secondsRemaining = self.loopSeconds
      } else {
        // do nothing
      }
    })
  }
  
  func pause() {
    miniTimer?.invalidate()
  }
  
  func stop() {
    miniTimer?.invalidate()
    secondsRemaining = loopSeconds
  }
}
