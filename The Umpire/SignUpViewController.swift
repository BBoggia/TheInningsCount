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
    
    var ref : DatabaseReference?
    var ref2 : DatabaseReference?
    let loginRef = ViewController()
    
    var userCity: String!
    var currentUser: Any!
    
    @IBOutlet var appTitle: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reTypePasswordField: UITextField!
    @IBOutlet weak var leagueCodeField: UITextField!
    @IBOutlet var altCreateAccBtn: UIButton!
    @IBAction func createAccountButton(_ sender: Any) {
        let myAlert = UIAlertController(title: "Confirm", message: "Is this correct?\nEmail: \(self.emailField.text!)\nLeague Code: \(self.leagueCodeField.text!)", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            self.checkAccDetails()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        ref2 = Database.database().reference().child("UserData")

        emailField.delegate = self
        passwordField.delegate = self
        reTypePasswordField.delegate = self
        leagueCodeField.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        emailField.inputAccessoryView = toolBar
        passwordField.inputAccessoryView = toolBar
        reTypePasswordField.inputAccessoryView = toolBar
        leagueCodeField.inputAccessoryView = toolBar
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            appTitle.font = UIFont(name: appTitle.font.fontName, size: 55)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkAccDetails() {
        
        ref?.child("LeagueData").observeSingleEvent(of: .value, with: { (snapshot) in
            if !(self.leagueCodeField.text!.isEmpty) && snapshot.hasChild(self.leagueCodeField.text!) {
        
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
                } else if !((self.emailField.text?.contains("@"))!) || !((self.emailField.text?.contains("."))!) {
                    
                    self.displayMyAlertMessage(title: "Oops!", userMessage: "It seems your email is missing something.")
                } else {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "toAgeSelect") as! SignupAgeTableViewController
                    vc.leagueCode = self.leagueCodeField.text!
                    vc.usrEmail = self.emailField.text!
                    vc.usrPass = self.passwordField.text!
                    self.navigationController?.pushViewController(vc,animated: true)
                }
            } else {
                
                self.displayMyAlertMessage(title: "Oops!", userMessage: "The league code you entered is invalid!")
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func displayMyAlertMessage(title:String, userMessage:String) {
        
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @objc func doneClicked() {
        self.view.endEditing(true)
    }
}
