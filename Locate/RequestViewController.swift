//
//  RequestViewController.swift
//  Locate
//
//  Created by Paul Ter on 8/6/19.
//  Copyright © 2019 Paul Ter. All rights reserved.
//

import UIKit
import Firebase

class RequestViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var requests = [[String:Any]]()
    var currentUserInfo = [String:Any]()
    @IBOutlet weak var requestTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMyInfo()
        getRequests()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RequestTableViewCell
        
        cell.acceptButton.tag = indexPath.row
        cell.denyButton.tag = indexPath.row
        
        let userID = self.requests[indexPath.row]["userID"] as! String
        let profilePic = self.requests[indexPath.row]["ProfilePic"] as! String
        let username = self.requests[indexPath.row]["Username"] as! String
        
        cell.usernameLabel.text = username
        
        
        
        let url = URL(string: profilePic)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print("Theres an error: " + error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!){
                    cell.profilePic.image = downloadedImage
                    
                    
                    
                }
            }
        }).resume()
        
        

        return cell
    }
    
    func getRequests(){
        Database.database().reference().child("Requests").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                print("RQ Dict \(dictionary)")
                for dict in dictionary.values{
                    self.requests.append(dict as! [String : Any])
                    DispatchQueue.main.async {
                        self.requestTable.reloadData()
                    }
                }
                
            }
        }
    }
    
    func getMyInfo(){
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                self.currentUserInfo = dictionary
            }
        }
    }
    

    @IBAction func acceptPressed(_ sender: Any) {
        
        
        // information from user who sent request
        let userInfo = self.requests[(sender as AnyObject).tag]
        let username = userInfo["Username"] as! String
        let userID = userInfo["userID"] as! String
        
        //get my friends and add their uid to array
        var myFriends = self.currentUserInfo["Friends"] as! [String]
        myFriends.append(userID)
        
       //update my friends
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["Friends":myFriends])
       
        //search database to retrieve their users info:  -> their friend array
        Database.database().reference().child("Users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                
                // add my uid to their friends
                var friends = dictionary["Friends"] as! [String]
                friends.append(Auth.auth().currentUser!.uid)
                
                //update their friends
                Database.database().reference().child("Users").child(userID).updateChildValues(["Friends":friends])
                
                //clear the request
                    Database.database().reference().child("Requests").child(Auth.auth().currentUser!.uid).child(userID).removeValue()
                
                
                //reload page
                let requests = self.storyboard?.instantiateViewController(withIdentifier: "Requests")
                
                self.present(requests!, animated: false, completion: nil)
                
                
               
            }
        }
        
        
        
        
        
    }
    
    @IBAction func denyPressed(_ sender: Any) {
        
        let userInfo = self.requests[(sender as AnyObject).tag]
        let username = userInfo["Username"] as! String
        let userID = userInfo["userID"] as! String
        
        Database.database().reference().child("Requests").child(Auth.auth().currentUser!.uid).child(userID).removeValue()
        

            // reload page
        let requests = self.storyboard?.instantiateViewController(withIdentifier: "Requests")
        
        self.present(requests!, animated: false, completion: nil)
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
