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
        
        createAccount()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAccount() {
        
        if (self.leagueName.text?.isEmpty)! || (self.password.text?.isEmpty)! || (self.rePassword.text?.isEmpty)! || (self.adminEmail.text?.isEmpty)! {
            
            displayMyAlertMessage(title: "Oops!", userMessage: "One or all of the text fields are empty!"
            )
        } else if self.password.text != self.rePassword.text {
            
            displayMyAlertMessage(title: "Oops!", userMessage: "Your passwords don't match!")
            
        } else {
            
            leagueName1 = leagueName.text
            email1 = adminEmail.text
            password1 = password.text
            
            performSegue(withIdentifier: "fromLeagueCreation", sender: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromLeagueCreation" {
            var teamNameVC: TeamNameViewController
            
            teamNameVC = segue.destination as! TeamNameViewController
            teamNameVC.leagueName = leagueName1 as String
            teamNameVC.email = email1 as String
            teamNameVC.password = password1 as String
            
        }
    }
    
}
