//
//  CompleteLeagueCreationViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/25/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class CompleteLeagueCreationViewController: UIViewController {

    let ref = FIRDatabase.database().reference()
    let ref2 = FIRDatabase.database().reference().child("User-Team").child("Admin")
    let loginRef = ViewController()
    
    var leagueName: String!
    var email: String!
    var password: String!
    var teams = [String]()
    var adminTeam = ""
    var changedData: String!
    var ageGroups = [String]()
    var randomGenNum: String!
    
    @IBOutlet weak var emailDisplay: UILabel!
    @IBOutlet weak var passwordDisplay: UILabel!
    @IBOutlet weak var leagueNameDisplay: UILabel!
    @IBOutlet weak var teamsDisplay: UILabel!
    @IBOutlet weak var adminsTeam: UILabel!
    @IBOutlet weak var leagueAges: UILabel!
    
    @IBAction func changeEmail(_ sender: Any) {
        displayMyAlertMessage(title: "Corrections", userMessage: "Enter the new email you want to use.", editedField: emailDisplay)
    }
    @IBAction func changePassword(_ sender: Any) {
        displayMyAlertMessage(title: "Corrections", userMessage: "Enter the new password you want to use.", editedField: passwordDisplay)
    }
    @IBAction func changeLeagueName(_ sender: Any) {
        displayMyAlertMessage(title: "Corrections", userMessage: "Enter the new league name you want to use.", editedField: leagueNameDisplay)
    }
    @IBAction func adminTeam(_ sender: Any) {
        displayMyAlertMessage(title: "Corrections", userMessage: "Enter the new name of your team.", editedField: adminsTeam)
    }
    @IBAction func confirm(_ sender: Any) {
        createAccount()
        autoSignIn()
        randomString()
        
        let myAlert = UIAlertController(title: "IMPORTANT!", message: "This 5 digit code is needed by your coaches when they create an account to be able to use the app. Write it down or it has been copied to your clipboard. \n|\n\(randomGenNum!)", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) {
        action in
            
        }
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
        
        while FIRAuth.auth()?.currentUser != nil {
            for item in self.teams {
                for item2 in self.ageGroups {
                    self.ref.child("LeagueDatabase").child(self.leagueNameDisplay.text!).child(item2).child(item).child("Long Date").setValue("Date | Player Number | Innings Pitched")
                }
            }
        }
        
        self.performSegue(withIdentifier: "fromCL", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailDisplay.text = email
        passwordDisplay.text = password
        leagueNameDisplay.text = leagueName
        teamsDisplay.text = teams.joined(separator: ", ")
        adminsTeam.text = adminTeam
        leagueAges.text = ageGroups.joined(separator: ", ")
        
        while FIRAuth.auth()?.currentUser != nil {
            saveUID()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createAccount() {
        
        FIRAuth.auth()?.createUser(withEmail: emailDisplay.text!, password: passwordDisplay.text!, completion: { (user, error) in
            if error == nil {
                self.autoSignIn()
                self.saveUID()
            } else {
                self.displayMyAlertMessageAlternate(title: "Oops!", userMessage: (error?.localizedDescription)!)
            }
        })
    }
    
    func saveUID() {
        
        let user = FIRAuth.auth()?.currentUser
        let userUID = user?.uid
        
        if adminTeam == "" && adminsTeam.text == "" {
            ref2.child("/\(userUID!)").setValue("N/A")
        } else {
            ref2.child("/\(userUID!)").setValue(adminTeam)
        }
        
        print(userUID!)
    }
    
    func autoSignIn() {
        FIRAuth.auth()?.signIn(withEmail: self.emailDisplay.text!, password: self.passwordDisplay.text!, completion: {
            (user, error) in
            if error == nil {
            }
        })
    }
    
    func randomString() {
        
        let letters : NSString = "0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< 5 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        self.randomGenNum = randomString
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func displayMyAlertMessage(title:String, userMessage:String, editedField:UILabel)
    {
        
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        myAlert.addTextField()
        
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
                self.changedData = myAlert.textFields![0].text
                editedField.text = self.changedData
            }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    func displayMyAlertMessageAlternate(title:String, userMessage:String)
    {
        
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: nil)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
}
