//
//  LeagueCreationViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/25/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LeagueCreationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var leagueName: UITextField!
    @IBOutlet weak var adminEmail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rePassword: UITextField!
    
    @IBAction func createAccount(_ sender: Any) {
        
        if (leagueName.text?.contains("$"))! || (leagueName.text?.contains("/"))! || (leagueName.text?.contains("\\"))! || (leagueName.text?.contains("#"))! || (leagueName.text?.contains("["))! || (leagueName.text?.contains("]"))! || (leagueName.text?.contains("."))! {
            displayMyAlertMessage(title: "Oops!", userMessage: "Your league name cannot contain the following characters \n '$' '.' '/' '\\' '#' '[' ']'")
        } else {
            createAccount()
        }
    }
    
    var leagueName1: String!
    var email1: String!
    var password1: String!
    var rePassword1: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.leagueName.delegate = self
        self.adminEmail.delegate = self
        self.password.delegate = self
        self.rePassword.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        leagueName.inputAccessoryView = toolBar
        adminEmail.inputAccessoryView = toolBar
        password.inputAccessoryView = toolBar
        rePassword.inputAccessoryView = toolBar
        
        //displayMyAlertMessage(title: "League Creation", userMessage: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createAccount() {
        
        if (self.leagueName.text?.isEmpty)! || (self.password.text?.isEmpty)! || (self.rePassword.text?.isEmpty)! || (self.adminEmail.text?.isEmpty)! {
            
            displayMyAlertMessage(title: "Oops!", userMessage: "One or all of the text fields are empty!"
            )
        } else if self.password.text != self.rePassword.text {
            
            displayMyAlertMessage(title: "Oops!", userMessage: "Your passwords don't match!")
            
        } else if (self.password.text?.characters.count)! < 6 {
            displayMyAlertMessage(title: "Oops!", userMessage: "Your password needs to contain atleast 6 characters.")
        } else {
            
            leagueName1 = leagueName.text
            email1 = adminEmail.text
            password1 = password.text
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ageCreate") as! TeamAgeGroupCreatorViewController
            vc.leagueName = leagueName1 as String
            vc.email = email1 as String
            vc.password = password1 as String
            navigationController?.pushViewController(vc,animated: true)
        }
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func doneClicked() {
        self.view.endEditing(true)
    }
    
}
