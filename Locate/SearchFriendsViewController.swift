//
//  SearchFriendsViewController.swift
//  Locate
//
//  Created by Paul Ter on 8/4/19.
//  Copyright © 2019 Paul Ter. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleMobileAds

class SearchFriendsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var searchTable: UITableView!
    
    var users = [[String:Any]]()
    var myFriends = [String]()
    var myUsername = ""
    var myProfilePic = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:Any]{
                    self.myFriends = dictionary["Friends"] as! [String]
                    self.myUsername = dictionary["Username"] as! String
                    self.myProfilePic = dictionary["ProfilePic"] as! String
                }
        }
        
        let view = GADBannerView()
        view.frame = CGRect(x: 0, y: self.view.frame.maxY - 50, width: 320, height: 50)
        view.delegate = self
        view.rootViewController = self
        view.adUnitID = "ca-app-pub-1666211014421581/1420692067"
        view.load(GADRequest())
        self.view.addSubview(view)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
        
        let userInfo = self.users[indexPath.row]
        let username = userInfo["Username"] as! String
        let email = userInfo["Email"] as! String
        let profilePic = userInfo["ProfilePic"] as! String
        cell.textLabel?.text = username
        cell.detailTextLabel?.text = email
        
        let url = URL(string: profilePic)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print("Theres an error: " + error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!){
                    
                    cell.imageView?.isHidden = true

                    cell.imageView?.image = downloadedImage
                    cell.imageView?.clipsToBounds = true
                    cell.imageView?.frame = CGRect(x: cell.imageView?.frame.origin.x ?? 0, y: cell.imageView?.frame.origin.y ?? 0, width: 30, height: 30)
                    cell.imageView?.contentMode = .scaleAspectFit
                    
                    cell.imageView?.isHidden = false

                    
                    
                    
                }
            }
        }).resume()
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = self.users[indexPath.row]
        
        let userID = userInfo["UserID"] as! String
        let username = userInfo["Username"] as! String
        let profilePic = userInfo["ProfilePic"] as! String
        var friends = myFriends
        var theirFriends = userInfo["Friends"] as! [String]
        
        print("selected username \(username)")
        
        
        //if my friends doesn't contain target uid, send them a request
        if(!friends.contains(userID)){
            print("First Friends count  \(friends.count)")

            friends.append(userID)
            print("Second Friends count  \(friends.count)")
            Database.database().reference().child("Requests").child(userID).child(Auth.auth().currentUser!.uid).updateChildValues(["userID":Auth.auth().currentUser!.uid,"Username":self.myUsername,"ProfilePic":self.myProfilePic])
            
            
            
            let alertController = UIAlertController(title: "Request Sent", message: "", preferredStyle: .alert)
            
            
            let okay = UIAlertAction(title: "Okay", style: .default) { action in
              let home = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                self.present(home!, animated: false, completion: nil)
              
                
            }
            
            
            
            alertController.addAction(okay)
            self.present(alertController, animated: true, completion: nil)
            
            
        }else{
            // my friends array contains the target uid, already friends
            let alertController = UIAlertController(title: "Already Friends", message: "", preferredStyle: .alert)
            
            
            let delete = UIAlertAction(title: "Delete Friend", style: .default) { action in
                
                var newFriends = [String]()
                
                for f in friends{
                    if(f != userID){
                        newFriends.append(f)
                    }
                }
                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["Friends":newFriends])
                
                var theirNewFriends = [String]()
                
                for f in theirFriends{
                    if(f != Auth.auth().currentUser!.uid){
                        theirNewFriends.append(f)
                    }
                }
                
                Database.database().reference().child("Users").child(userID).updateChildValues(["Friends":theirNewFriends])
                
                
                let alert2 = UIAlertController(title: "Deleted Friend", message: "They will no longer see each other's location", preferredStyle: UIAlertController.Style.alert)
                
                alert2.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                        let home = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(home!, animated: true, completion: nil)
                    
                })
                )
                self.present(alert2, animated: true, completion: nil)
                
               
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (ac) in
                
            }
            
            alertController.addAction(delete)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.users = [[String:Any]]()
        self.searchTable.reloadData()
        
        let ref = Database.database().reference()
        ref.child("Users").queryOrdered(byChild: "CapitalUsername").queryStarting(atValue: searchText.uppercased()).queryEnding(atValue: "\(searchText.uppercased())\\uf8ff")
            .observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                
                if let dictionary = snapshot.value as? [String:Any]{
                    for dict in dictionary.values{
                        let dict2 = dict as? [String:Any]
                        
                        self.users.append(dict2!)

                        //self.users = [dict2!]
                        DispatchQueue.main.async{
                            
                            self.searchTable.reloadData()
                        }
                    }
                    
                }
            })
        
        let ref2 = Database.database().reference()
        ref2.child("Users").queryOrdered(byChild: "FullName").queryStarting(atValue: searchText.uppercased()).queryEnding(atValue: "\(searchText.uppercased())\\uf8ff")
            .observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                
                if let dictionary = snapshot.value as? [String:Any]{
                    for dict in dictionary.values{
                        let dict2 = dict as? [String:Any]
                        
                        self.users.append(dict2!)
                        DispatchQueue.main.async{
                            
                            self.searchTable.reloadData()
                        }
                    }
                    
                }
            }
        )
    }
    
    
    

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SearchFriendsViewController: GADBannerViewDelegate{
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
}
