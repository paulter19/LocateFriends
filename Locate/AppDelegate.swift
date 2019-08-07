//
//  AppDelegate.swift
//  Locate
//
//  Created by Paul Ter on 8/3/19.
//  Copyright © 2019 Paul Ter. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GoogleMobileAds



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    var timer: Timer?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Entered the background")
        timer?.invalidate()
        endBackgroundTask()
        if(locationManager.location != nil){
            updateCurrentLocation(location: locationManager.location!)
        }
        backgroundTask = UIApplication.shared.beginBackgroundTask (expirationHandler: {
            self.endBackgroundTask()
        })
        let defaults = UserDefaults.standard
        defaults.set("1", forKey: "background")
        
        self.timer = Timer.scheduledTimer(timeInterval: 900, target: self, selector: #selector(AppDelegate.checkBackgroundTimeRemaining), userInfo: nil, repeats: true)
    }
    
    @objc func checkBackgroundTimeRemaining() {
        let defaults = UserDefaults.standard
        
        let Activeusercountcheck = defaults.string(forKey: "background")
        if(Activeusercountcheck == "1"){
            
            self.locationManager.startUpdatingLocation()
            if(locationManager.location != nil){
                updateCurrentLocation(location: locationManager.location!)
            }
            
            
        }else{
            print("Activeusercountcheck != 1")
        }
        
        
    }
    
    @objc func endBackgroundTask() {
        if self.backgroundTask != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.backgroundTask.rawValue))
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        timer?.invalidate()
        self.endBackgroundTask()
    }
    
    func updateCurrentLocation(location: CLLocation){
        var time = (Int)(Date.timeIntervalSinceReferenceDate)
        Database.database().reference().child("Locations").child(Auth.auth().currentUser!.uid).updateChildValues(["Username":Auth.auth().currentUser?.displayName,"latitude":location.coordinate.latitude,"longitude":location.coordinate.longitude,"lastUpdated":time,"UserID":Auth.auth().currentUser!.uid])
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
        return UIBackgroundTaskIdentifier(rawValue: input)
    }


}



