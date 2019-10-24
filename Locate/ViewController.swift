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
import GoogleMobileAds

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate,UITableViewDataSource  {
   
    

    let regionRadius: CLLocationDistance = 5000
    let locationManager = CLLocationManager()
    var myFriends = [String]()
    var visibility = ""
    var friendsDictionary = [[String:Any]]()

    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var notificationBell: UIButton!
    
    @IBOutlet weak var searchFriendsButton: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        locationManager.startUpdatingLocation()
        
        let view = GADBannerView()
        view.frame = CGRect(x: 0, y: self.view.frame.maxY - 50, width: self.view.frame.width, height: 50)
        view.delegate = self
        view.rootViewController = self
        view.adUnitID = "ca-app-pub-1666211014421581/1420692067"
        view.load(GADRequest())
        self.view.addSubview(view)
        
        
        self.searchFriendsButton.layer.cornerRadius = 10
        
        
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        checkIfUserSignedIn()
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.friendsDictionary.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friend = self.friendsDictionary[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = friend["Username"] as! String
        let lastUpdated = friend["lastUpdated"] as! TimeInterval
        let dateObject = Date.init(timeIntervalSinceReferenceDate: lastUpdated)
        //cell.imageView?.image = UIImage(named: "friends.png")
        //cell.imageView?.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        if(NSCalendar.current.isDateInToday(dateObject)){
            print("tup - today")
            cell.detailTextLabel!.text = "Updated today: \( DateFormatter.localizedString(from: dateObject, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short))"

                   }
        else if(NSCalendar.current.isDateInYesterday(dateObject)){
            print("tup - yesterday")

            cell.detailTextLabel!.text = "Updated yesterday:" + DateFormatter.localizedString(from: dateObject, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
                   }
        else{
            print("tup - ???")

            cell.detailTextLabel!.text = "Updated: " + DateFormatter.localizedString(from: dateObject, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
                   }
        
      
        
        
        
        return cell
        
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = self.friendsDictionary[indexPath.row]
        let long = friend["longitude"] as! Double
        let lat = friend["latitude"] as! Double
        
        let location = CLLocation(latitude: lat, longitude: long)
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapKit.setRegion(coordinateRegion, animated: true)

    }
    
    func checkIfUserSignedIn(){
        
        if(Auth.auth().currentUser == nil){
            print("no user signed in")
            let signInView = (self.storyboard?.instantiateViewController(withIdentifier: "SignIn"))!
            self.present(signInView, animated: false, completion: nil)
        }else{
            getMyVisibility()
            findFriendsLocation()
            getRequests()

        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapKit.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = "Current Location \(self.visibility)"
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
        
        if(manager.location != nil){
            updateCurrentLocation(location: manager.location!)
            centerMapOnLocation(location: locationManager.location ?? CLLocation(latitude: 47, longitude: -91))
        }
        locationManager.stopUpdatingLocation()
    }
    
    func updateCurrentLocation(location: CLLocation){
        var time = (Int)(Date.timeIntervalSinceReferenceDate)
       
        //first get visibility
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:Any]{
                self.visibility = dictionary["Visibility"] as! String

                //update location
                
                Database.database().reference().child("Locations").child(Auth.auth().currentUser!.uid).updateChildValues(["Username":Auth.auth().currentUser?.displayName,"latitude":location.coordinate.latitude,"longitude":location.coordinate.longitude,"lastUpdated":time,"UserID":Auth.auth().currentUser!.uid,"Visibility":self.visibility])
                
                
            }
        }
        
    }

    @IBAction func menuPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Menu", message: "", preferredStyle: .alert)
        
        var visibilityLabel = ""
        if(self.visibility == "On"){
            visibilityLabel = "Hide Visibility"
        }else{
            visibilityLabel = "Show Visibility"
        }
        
        let visibility = UIAlertAction(title: visibilityLabel, style: .default) { action in
            
            if(self.visibility == "On"){
                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["Visibility":"Off"])
            }else{
                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["Visibility":"On"])
                
            }
            
           
            
            let home = (self.storyboard?.instantiateViewController(withIdentifier: "Home"))!
            self.present(home, animated: false, completion: nil)
        }
        
        
        
        
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
        
        alertController.addAction(visibility)
        alertController.addAction(logout)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func findFriendsLocation(){
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                print("Current user is \(dictionary["Username"])")
                self.myFriends = dictionary["Friends"] as! [String]
                self.visibility = dictionary["Visibility"] as! String
               
                for f in self.myFriends{
                    Database.database().reference().child("Locations").queryOrdered(byChild: "UserID").queryEqual(toValue: f).observeSingleEvent(of: .value, with: { (snapshot) in
                       if let dictionary = snapshot.value as? [String:Any]{
                        for dict in dictionary.values{
                            let dict2 = dict as! [String:Any]
                        if let username = dict2["Username"] as? String{
                            print("Username is \(username)")

                            if let userVisibility = dict2["Visibility"] as? String{
                                if(userVisibility == "On"){
                                    self.friendsDictionary.append(dict2)
                                    print("Visibility is On")
                                    let annotation = MKPointAnnotation()
                                    
                                    annotation.title = username
                                    
                                    let lastUpdated = dict2["lastUpdated"] as! TimeInterval
                                    
                                    let latitude = dict2["latitude"] as! Double
                                    let longitude = dict2["longitude"] as! Double
                                    
                                    annotation.subtitle = DateFormatter.localizedString(from: Date.init(timeIntervalSinceReferenceDate: lastUpdated ), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
                                    annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                                    
                                    
                                    self.mapKit.addAnnotation(annotation)
                                }else{
                                    print("visibility was off")
                                }
                               
                            }
                        
                        }// end if let username
                        }
                        }// end for dict in dictionary.values
                        
                        DispatchQueue.main.async {
                            self.friendsTableView.reloadData()
                        }
                    })//end database.database()
                }
            }
        }
    }
    
    
    
    func getRequests(){
        Database.database().reference().child("Requests").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            //  check if you have notifications
            if(snapshot.exists()){
                //change notification bell
                let bellImage = UIImage(named: "newNotification.png")
                self.notificationBell.setImage(bellImage, for: .normal);
                
            }
        }
    }
    
    func getMyVisibility(){
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in

            if let dictionary = snapshot.value as? [String:Any]{
                self.visibility = dictionary["Visibility"] as! String
                print("My visibility is \(self.visibility)")
                
            }
        }
    }
    
   
    
}
extension ViewController: MKMapViewDelegate, GADBannerViewDelegate, GADInterstitialDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "reuse") as? MKMarkerAnnotationView
        
        if(view == nil){
            view = MKMarkerAnnotationView(annotation: nil, reuseIdentifier: "reuse")
            
        }
        view?.annotation = annotation
        view?.displayPriority = .required
        return view
    }
    
    func loadInterstitialAd(){
        var  interstitial = GADInterstitial(adUnitID: "ca-app-pub-1666211014421581/7156234473")
        interstitial.delegate = self
        
        interstitial.load(GADRequest())
    
        if interstitial.isReady {
            print("interstitial ready")
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready :(")
        }
    }
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    
    //interstitial protocols
    
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}

