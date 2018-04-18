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
    
    var userCity: String!
    var currentUser: Any!
    
    @IBOutlet var appTitle: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reTypePasswordField: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
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
        
        Refs().dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !(self.leagueCodeField.text!.isEmpty) && snapshot.hasChild(self.leagueCodeField.text!) {
        
                if (self.emailField.text?.isEmpty)! || (self.passwordField.text?.isEmpty)! || (self.reTypePasswordField.text?.isEmpty)! || (self.leagueCodeField.text?.isEmpty)! {
                    
                    self.displayAlert(title: "Oops!", message: "One or all of the text fields is empty!")
                } else if self.passwordField.text != self.reTypePasswordField.text {
                    
                    self.displayAlert(title: "Oops!", message: "Your passwords dont match!")
                } else if !((self.emailField.text?.contains("@"))!) || !((self.emailField.text?.contains("."))!) {
                    
                    self.displayAlert(title: "Oops!", message: "It seems your email is missing something.")
                } else {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "toAgeSelect") as! SignupAgeTableViewController
                    vc.leagueCode = self.leagueCodeField.text!
                    vc.usrEmail = self.emailField.text!
                    vc.usrPass = self.passwordField.text!
                    vc.firstName = self.firstName.text!
                    vc.lastName = self.lastName.text!
                    self.navigationController?.pushViewController(vc,animated: true)
                }
            } else {
                
                self.displayAlert(title: "Oops!", message: "The league code you entered is invalid!")
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    @objc func doneClicked() {
        self.view.endEditing(true)
    }
}
