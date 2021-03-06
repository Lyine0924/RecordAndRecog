//
//  AppDelegate.swift
//  DemoRecorder
//
//  Created by Kiran Kumar on 3/15/19.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//
//  Following tutorial from https://www.youtube.com/watch?v=_d_tJ9B12CY
//      IOS 11, Swift 4, Intermediate, Tutorial : How to Record and Play Audio in Swift ( AVFoundation)

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let recorderAndPlayer : VoiceService = VoiceService.sharedInstance


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        pauseRecorderAndPlayerActivity()
    }
    // 앱이 백그라운드 상태가 되었을 때
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        pauseRecorderAndPlayerActivity()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        stopRecorderAndPlayerActivity()
    }

    func pauseRecorderAndPlayerActivity() {
        
        if recorderAndPlayer.isPlaying() {
            recorderAndPlayer.pausePlayback()
        }
        else if recorderAndPlayer.isRecording() {
            recorderAndPlayer.stopRecording()
        }
    }
    
    func stopRecorderAndPlayerActivity() {
        if recorderAndPlayer.isPlaying() {
            recorderAndPlayer.stopPlayback()
        }
        else if recorderAndPlayer.isRecording() {
            recorderAndPlayer.stopRecording()
        }
    }

}

