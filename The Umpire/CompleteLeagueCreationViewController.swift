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
    
    @IBOutlet weak var emailDisplay: UILabel!
    @IBOutlet weak var passwordDisplay: UILabel!
    @IBOutlet weak var leagueNameDisplay: UILabel!
    @IBOutlet weak var teamsDisplay: UILabel! //THIS IS BROKE
    @IBOutlet weak var adminsTeam: UILabel!
    
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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailDisplay.text = email
        passwordDisplay.text = password
        leagueNameDisplay.text = leagueName
        teamsDisplay.text = teams.joined(separator: ", ")
        adminsTeam.text = adminTeam
        
        while FIRAuth.auth()?.currentUser != nil {
            saveUID()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAccount() {
        
        FIRAuth.auth()?.createUser(withEmail: emailDisplay.text!, password: passwordDisplay.text!, completion: { (user, error) in
            if error == nil {
                
                for team in self.teams {
                    self.ref.child("LeagueDatabase").child(self.leagueNameDisplay.text!).child(team)
                }
                
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
