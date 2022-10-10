//
//  AppDelegate.swift
//  Videlay
//
//  Created by June Kim on 10/2/22.
//

import UIKit
import Crisp

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    CrispSDK.configure(websiteID: "62d915a3-57bd-4867-af7b-b6bdb2bd3510")
    
    if !UserDefaults.standard.bool(forKey: "firstlaunch") {
      UserDefaults.standard.setValue(true, forKey: "firstlaunch")
      UserDefaults.standard.set(9, forKey: ConfigViewController.durationControlRowKey)
      UserDefaults.standard.set(0, forKey: ConfigViewController.intervalControlRowKey)
    }
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

