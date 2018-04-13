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
    @IBOutlet weak var textFieldStack: UIStackView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var confirm: UIButton!
    
    @IBAction func createAccount(_ sender: Any) {
        
        if leagueName.text?.rangeOfCharacter(from: charSet) != nil {
            displayAlert(title: "Oops!", message: "Your league name cannot contain the following characters: \n '$' '.' '/' '\\' '#' '[' ']'")
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
        
        let defaults = UserDefaults.standard
        
        if ((defaults.array(forKey: "leagueData")) != nil) {
            
            defaults.mutableArrayValue(forKey: "leagueData").removeAllObjects()
        }
        
        var placeHolderArr: [[String:[String]]] = []
        placeHolderArr.append(["placeHolder":["placeHolder"]])
        defaults.set(placeHolderArr, forKey: "leagueData")
        
        self.leagueName.delegate = self
        self.adminEmail.delegate = self
        self.password.delegate = self
        self.rePassword.delegate = self
        self.firstName.delegate = self
        self.lastName.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        leagueName.inputAccessoryView = toolBar
        adminEmail.inputAccessoryView = toolBar
        password.inputAccessoryView = toolBar
        rePassword.inputAccessoryView = toolBar
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleLbl.frame = CGRect(x: 16, y: 16, width: view.frame.width - 32, height: textFieldStack.frame.minY)
            titleLbl.font = UIFont(name: titleLbl.font.fontName, size: 60)
            confirm.titleLabel?.font = UIFont(name: (confirm.titleLabel?.font.fontName)!, size: 50)
            textFieldStack.spacing += 18
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createAccount() {
        
        if (self.leagueName.text?.isEmpty)! || (self.password.text?.isEmpty)! || (self.rePassword.text?.isEmpty)! || (self.adminEmail.text?.isEmpty)! || (self.firstName.text?.isEmpty)! || (self.lastName.text?.isEmpty)! {
            
            displayAlert(title: "Oops!", message: "One or all of the text fields are empty!")
        } else if self.password.text != self.rePassword.text {
            
            displayAlert(title: "Oops!", message: "Your passwords don't match!")
        } else if (self.password.text?.count)! < 6 {
            
            displayAlert(title: "Oops!", message: "Your password needs to contain atleast 6 characters.")
        } else if !((self.adminEmail.text?.contains("@"))!) || !((self.adminEmail.text?.contains("."))!) {
            
            displayAlert(title: "Oops!", message: "It seems your email is missing something.")
        } else if self.leagueName.text?.rangeOfCharacter(from: charSet) != nil  {
            
            displayAlert(title: "Oops!", message: "Your team name cannot contain the following characters. \n '$' '.' '/' '\\' '#' '[' ']'")
        } else {
            
            leagueName1 = leagueName.text
            email1 = adminEmail.text
            password1 = password.text
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ageCreate") as! TeamAgeGroupCreatorViewController
            vc.leagueName = leagueName1 as String
            vc.email = email1 as String
            vc.password = password1 as String
            vc.firstName = firstName.text
            vc.lastName = lastName.text
            navigationController?.pushViewController(vc,animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    @objc func doneClicked() {
        self.view.endEditing(true)
    }
    
}
