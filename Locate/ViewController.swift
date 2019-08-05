//
//  ViewController.swift
//  Locate
//
//  Created by Paul Ter on 8/3/19.
//  Copyright © 2019 Paul Ter. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, CLLocationManagerDelegate  {

    let regionRadius: CLLocationDistance = 5000
    let locationManager = CLLocationManager()
    var myFriends = [String]()

    @IBOutlet weak var mapKit: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
       // centerMapOnLocation(location: CLLocation(latitude: 44, longitude: -91))

        locationManager.startUpdatingLocation()
        
        
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfUserSignedIn()
        

    }
    
    func checkIfUserSignedIn(){
        
        if(Auth.auth().currentUser == nil){
            print("no user signed in")
            let signInView = (self.storyboard?.instantiateViewController(withIdentifier: "SignIn"))!
            self.present(signInView, animated: false, completion: nil)
        }else{
            findFriendsLocation()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapKit.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = "Current Location"
        //You can also add a subtitle that displays under the annotation such as
        annotation.subtitle = DateFormatter.localizedString(from: Date.init(), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
        annotation.coordinate = location.coordinate
        
        mapKit.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        print("error did not update location!!")

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update location!!")
        centerMapOnLocation(location: locationManager.location ?? CLLocation(latitude: 47, longitude: -91))
        if(manager.location != nil){
            updateCurrentLocation(location: manager.location!)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func updateCurrentLocation(location: CLLocation){
        var time = (Int)(Date.timeIntervalSinceReferenceDate)
        Database.database().reference().child("Locations").child(Auth.auth().currentUser!.uid).updateChildValues(["Username":Auth.auth().currentUser?.displayName,"latitude":location.coordinate.latitude,"longitude":location.coordinate.longitude,"lastUpdated":time,"UserID":Auth.auth().currentUser!.uid])
    }

    @IBAction func menuPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Menu", message: "", preferredStyle: .alert)
        
        
        let logout = UIAlertAction(title: "Logout", style: .default) { action in
            do  {
                try Auth.auth().signOut()
                let signInView = (self.storyboard?.instantiateViewController(withIdentifier: "SignIn"))!
                self.present(signInView, animated: false, completion: nil)
            }catch{
                
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (ac) in
            
        }
        
        alertController.addAction(logout)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func findFriendsLocation(){
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                self.myFriends = dictionary["Friends"] as! [String]
               
                for f in self.myFriends{
                    print("There id is \(f)")
                    Database.database().reference().child("Locations").queryOrdered(byChild: "UserID").queryEqual(toValue: f).observeSingleEvent(of: .value, with: { (snapshot) in
                       if let dictionary = snapshot.value as? [String:Any]{
                        print("Snapshot value \(snapshot)")
                        let annotation = MKPointAnnotation()
                        for dict in dictionary.values{
                            let dict2 = dict as! [String:Any]
                        if let username = dict2["username"] as? String{
                            print("Username is \(username)")
                        annotation.title = username
                            
                            let lastUpdated = dict2["lastUpdated"] as! TimeInterval
                            
                            let latitude = dict2["latitude"] as! Double
                            let longitude = dict2["longitude"] as! Double
                        
                        annotation.subtitle = DateFormatter.localizedString(from: Date.init(timeIntervalSinceReferenceDate: lastUpdated ), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
                            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                        
                            
                            self.mapKit.addAnnotation(annotation)
                        }// end if let username
                        }
                        }// end for dict in dictionary.values
                    })//end database.database()
                }
            }
        }
    }
    
}

