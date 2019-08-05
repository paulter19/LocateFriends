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

class SearchFriendsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var searchTable: UITableView!
    
    var users = [[String:Any]]()
    var myFriends = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:Any]{
                    self.myFriends = dictionary["Friends"] as! [String]
                }
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
        
        let userInfo = self.users[indexPath.row]
        let username = userInfo["Username"] as! String
        let email = userInfo["Email"] as! String
        
        cell.textLabel?.text = username
        cell.detailTextLabel?.text = email
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = self.users[indexPath.row]
        
        let userID = userInfo["UserID"] as! String
        var friends = myFriends
        var theirFriends = userInfo["Friends"] as! [String]
        
        if(!friends.contains(userID)){
            print("First Friends count  \(friends.count)")

            friends.append(userID)
            print("Second Friends count  \(friends.count)")
            Database.database().reference().child("Requests").child(userID).child(Auth.auth().currentUser!.uid).updateChildValues(["ActiveRequest":"Yes"])
            
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["Friends":friends])
            
            let alertController = UIAlertController(title: "Added", message: "", preferredStyle: .alert)
            
            
            let okay = UIAlertAction(title: "Okay", style: .default) { action in
              let home = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                self.present(home!, animated: false, completion: nil)
              
                
            }
            
            
            
            alertController.addAction(okay)
            self.present(alertController, animated: true, completion: nil)
            
            
        }else{
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
        let ref = Database.database().reference()
        ref.child("Users").queryOrdered(byChild: "CapitalUsername").queryStarting(atValue: searchText.uppercased()).queryEnding(atValue: "\(searchText.uppercased())\\uf8ff")
            .observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                
                if let dictionary = snapshot.value as? [String:Any]{
                    for dict in dictionary.values{
                        let dict2 = dict as? [String:Any]
                        
                        self.users = [dict2!]
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
