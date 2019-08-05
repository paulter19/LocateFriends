//
//  SignUpViewController.swift
//  Locate
//
//  Created by Paul Ter on 8/3/19.
//  Copyright © 2019 Paul Ter. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    var profilePic = UIImage(named: "profile-img.jpg")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
       

    }
    

    @IBAction func signUpPressed(_ sender: Any) {
        
        if((username.text?.count)! < 4 || (password.text?.count)! < 4 || (email.text?.count)! < 4 ){
            let alert = UIAlertController(title: "Username and Password must be atleast 4 characters", message: "", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                //self.dismiss(animated: true, completion: nil)
            })
            )
            self.present(alert, animated: true, completion: nil)
        }else{
        
            if(checkIfUsernameTaken(username: username.text!) == false){
                Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: { (user, error) in
                    if(error != nil){
                        print("error")
                        print(error)
                        return
                    }
                    let storageRef = Storage.storage().reference().child("ProfilePics").child((Auth.auth().currentUser?.uid)!)
                    if let uploadData = self.profilePic!.jpegData(compressionQuality: 0.1){
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                            storageRef.downloadURL(completion: { (downloadURL, error) in
                                if error != nil{
                                    print(error)
                                    return
                                }
                                let ref = Database.database().reference().child("Users")
                                let userID = user?.user.uid
                                let newUserReference = ref.child(userID!)
                                
                                
                                newUserReference.setValue(["Username":self.username.text,"Email":self.email.text,"UserID":userID,"Friends":[Auth.auth().currentUser?.uid],"ProfilePic":downloadURL?.absoluteString,"CapitalUsername":self.username.text?.uppercased(),])
                                let changeRequest = user?.user.createProfileChangeRequest()
                                
                                changeRequest?.displayName = self.username.text
                                changeRequest?.photoURL = URL(string: (downloadURL?.absoluteString)!)
                                print("user ID is \(userID)")
                                
                                
                                changeRequest?.commitChanges { error in
                                    if let error = error {
                                        print(error)
                                    } else {
                                        // Profile updated.
                                        
                                       
                                    }
                                }
                                
                            })
                            
                            let home = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                            self.present(home!, animated: true, completion: nil)
                            
                        })// end storage.put
                    }//end if le upload data
                    
                })// end auth create user
            }
            
        }//end else
        
    }
    
    func checkIfUsernameTaken(username: String) -> Bool{
        var exists = false;
        Database.database().reference().child("Users").queryOrdered(byChild: "Username").queryEqual(toValue: username).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                
                let alert = UIAlertController(title: "Username already taken", message: "", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                    //self.dismiss(animated: true, completion: nil)
                })
                )
                self.present(alert, animated: true, completion: nil)
                
                exists =  true
            }
           
            
        }
        return exists
    }
    
    @IBAction func chooseProfilePic(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        print("dismiss keyboard")
        view.endEditing(true)
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

extension SignUpViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        if let originalImage = info["UIImagePickerControllerEditedImage"]{
            print("edited image")
            self.profilePicImageView.image = originalImage as? UIImage
            self.profilePic = originalImage as? UIImage
            dismiss(animated: true, completion: nil)
            
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"]  {
            print("original image")
            self.profilePicImageView.image = originalImage as? UIImage
            self.profilePic = originalImage as? UIImage
            dismiss(animated: true, completion: nil)
            
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("dismissed image picker")
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
}

