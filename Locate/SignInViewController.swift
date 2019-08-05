//
//  SignInViewController.swift
//  Locate
//
//  Created by Paul Ter on 8/3/19.
//  Copyright © 2019 Paul Ter. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
            
            if(Auth.auth().currentUser != nil){
                print("no user signed in")
                let home = (self.storyboard?.instantiateViewController(withIdentifier: "Home"))!
                self.present(home, animated: false, completion: nil)
            }
        
    }
    

    @IBAction func signInPressed(_ sender: Any) {
        let userN = self.email.text
        let pass = self.password.text
        
        Auth.auth().signIn(withEmail: userN!, password: pass!) { (user, error) in
            if(error == nil){
                print("sucess signing in")
                
                let home = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! ViewController
                self.present(home, animated: false, completion: nil)
                
            }else{
                let alert = UIAlertController(title: "Invalid Username or Password", message: "Check Capitalization", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                })
                )
                self.present(alert, animated: true, completion: nil)
                
            }
            
            
            
        }
        
        
        
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
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
