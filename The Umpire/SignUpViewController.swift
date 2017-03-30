//
//  SignUpViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 12/1/16.
//  Copyright © 2016 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    let ref = FIRDatabase.database()
    let ref2 = FIRDatabase.database().reference().child("User-Team").child("Coach")
    let loginRef = ViewController()
    
    var userCity: String!
    var currentUser: Any!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reTypePasswordField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBAction func createAccountButton(_ sender: Any) {
        createAccount()
        autoSignIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        while FIRAuth.auth()?.currentUser != nil {
            autoLoginSegue()
        }

        emailField.delegate = self
        passwordField.delegate = self
        reTypePasswordField.delegate = self
        cityField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAccount() {
        
        if (self.emailField.text?.isEmpty)! || (self.passwordField.text?.isEmpty)! || (self.reTypePasswordField.text?.isEmpty)! || (self.cityField.text?.isEmpty)! {
            
            let alertController = UIAlertController(title: "Oops!", message: "One or all of the text fields is empty!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else if self.passwordField.text != self.reTypePasswordField.text {
            
            let alertController = UIAlertController(title: "Oops!", message: "Your passwords dont match!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                if error == nil {
                    
                    self.autoLoginSegue()
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        
    }
    
    func autoSignIn() {
        FIRAuth.auth()?.signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: {
            (user, error) in
            
            if error == nil {
                
            }
        })
    }
    
    func autoLoginSegue() {
        
        self.emailField.text = ""
        self.passwordField.text = ""
        
        self.performSegue(withIdentifier: "signupWork", sender: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }

}
