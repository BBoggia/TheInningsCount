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
    let ref2 = FIRDatabase.database().reference().child("User Data")
    let loginRef = ViewController()
    
    var userCity: String!
    var currentUser: Any!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reTypePasswordField: UITextField!
    @IBOutlet weak var leagueCodeField: UITextField!
    @IBAction func createAccountButton(_ sender: Any) {
        self.createAccount()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        passwordField.delegate = self
        reTypePasswordField.delegate = self
        leagueCodeField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createAccount() {
        
        ref.reference().child("LeagueCodes").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.leagueCodeField.text!) {
        
                if (self.emailField.text?.isEmpty)! || (self.passwordField.text?.isEmpty)! || (self.reTypePasswordField.text?.isEmpty)! || (self.leagueCodeField.text?.isEmpty)! {
            
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
                    
                            self.performSegue(withIdentifier: "toTeamSelect", sender: nil)
                    
                        } else {
                    
                            let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                    
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
                }
            } else {
                self.displayMyAlertMessage(title: "Oops!", userMessage: "The league code you entered does not exist!")
            }
        })
        
        self.autoSignIn()
    }
    
    func autoSignIn() {
        FIRAuth.auth()?.signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: {
            (user, error) in
            
            if error == nil {
                
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTeamSelect" {
            
            var vC: SignupTeamSelectViewController
            
            vC = segue.destination as! SignupTeamSelectViewController
            
            vC.randomNum = leagueCodeField.text!
        }
    }

}
