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
    
    let loginRef = ViewController()
    
    var currentUser: Any!
    
    @IBOutlet var appTitle: UILabel!
    @IBOutlet weak var inputStack: UIStackView!
    @IBOutlet weak var labelStack: UIStackView!
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var backgroundLabel: UILabel!
    @IBOutlet var textFieldLabels: [UILabel]!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reTypePasswordField: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var leagueCodeField: UITextField!
    @IBOutlet var altCreateAccBtn: UIButton!
    @IBAction func createAccountButton(_ sender: Any) {
        if (leagueCodeField.text?.isEmpty)! {
            let myAlert = UIAlertController(title: "Confirm", message: "Is this correct?\n\nEmail: \(self.emailField.text!)\nName: \(firstName.text! + " " + lastName.text!)", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
                self.checkAccDetails()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            myAlert.addAction(okAction)
            myAlert.addAction(cancelAction)
            self.present(myAlert, animated: true, completion: nil)
        } else {
            let myAlert = UIAlertController(title: "Confirm", message: "Is this correct?\n\nEmail: \(self.emailField.text!)\nName: \(firstName.text! + " " + lastName.text!)\nLeague Code: \(self.leagueCodeField.text!)", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
                self.checkAccDetails()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            myAlert.addAction(okAction)
            myAlert.addAction(cancelAction)
            self.present(myAlert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        passwordField.delegate = self
        reTypePasswordField.delegate = self
        leagueCodeField.delegate = self
        firstName.delegate = self
        lastName.delegate = self
        
        backgroundLabel.frame.size.height = 230
        backgroundLabel.layer.cornerRadius = 10
        backgroundLabel.layer.masksToBounds = true
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: false)
        
        emailField.inputAccessoryView = toolBar
        passwordField.inputAccessoryView = toolBar
        reTypePasswordField.inputAccessoryView = toolBar
        leagueCodeField.inputAccessoryView = toolBar
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            appTitle.font = UIFont.boldSystemFont(ofSize: 66)
            for item in textFieldLabels {
                item.font = UIFont(name: item.font.familyName, size: 26)
            }
            firstName.font = UIFont(name: (firstName.font?.familyName)!, size: 24)
            firstName.frame.size.height = textFieldLabels[0].frame.height
            lastName.font = UIFont(name: (firstName.font?.familyName)!, size: 24)
            emailField.font = UIFont(name: (firstName.font?.familyName)!, size: 24)
            passwordField.font = UIFont(name: (firstName.font?.familyName)!, size: 24)
            reTypePasswordField.font = UIFont(name: (firstName.font?.familyName)!, size: 24)
            leagueCodeField.font = UIFont(name: (firstName.font?.familyName)!, size: 24)
            altCreateAccBtn.titleLabel?.font = UIFont(name: (altCreateAccBtn.titleLabel?.font.fontName)!, size: 50)
            backgroundLabel.frame.size.height = 345
            labelStack.spacing = 24
            textStack.spacing = 24
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkAccDetails() {
        
        Refs().dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
            if (self.emailField.text?.isEmpty)! || (self.passwordField.text?.isEmpty)! || (self.reTypePasswordField.text?.isEmpty)! || (self.firstName.text?.isEmpty)! || (self.lastName.text?.isEmpty)! {
                
                self.displayAlert(title: "Oops!", message: "One or all of the text fields is empty!")
            } else if self.passwordField.text != self.reTypePasswordField.text {
                
                self.displayAlert(title: "Oops!", message: "Your passwords don't match!")
            } else if !((self.emailField.text?.contains("@"))!) || !((self.emailField.text?.contains("."))!) {
                
                self.displayAlert(title: "Oops!", message: "It seems your email is missing something.")
            } else {
                if !(self.leagueCodeField.text!.isEmpty) {
                    if snapshot.hasChild(self.leagueCodeField.text!) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "toAgeSelect") as! SignupAgeTableViewController
                        vc.leagueCode = self.leagueCodeField.text!
                        vc.usrEmail = self.emailField.text!
                        vc.usrPass = self.passwordField.text!
                        vc.firstName = self.firstName.text!
                        vc.lastName = self.lastName.text!
                        self.navigationController?.pushViewController(vc,animated: true)
                    } else {
                        self.displayAlert(title: "Oops!", message: "The league code you entered is invalid!")
                    }
                } else {
                    self.createAccount()
                }
            }
        })
    }
    
    func createAccount() {
        Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
            if error == nil {
                self.autoSignIn()
            } else {
                self.displayAlert(title: "Oops!", message: "Error creating account: " + (error?.localizedDescription)!)
                print("Error creating account:", error?.localizedDescription as! String)
            }
        })
    }
    
    func autoSignIn() {
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: {
            (user, error) in
            if error == nil {
                Refs().usrRef.child((user?.uid)!).setValue(["FirstName" : "\(self.firstName.text!)", "LastName" : "\(self.lastName.text!)", "UID" : user?.uid, "Email" : self.emailField.text!])
                self.autoLogOut()
            }
        })
    }
    
    func autoLogOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.performSegue(withIdentifier: "signupToNav", sender: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    @objc func doneClicked() {
        self.view.endEditing(true)
    }
}
