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

    let ref = FIRDatabase.database()
    let ref2 = FIRDatabase.database().reference().child("User-Team").child("Admin")
    let loginRef = ViewController()
    
    var leagueName: String!
    var email: String!
    var password: String!
    var teams = ["test", "test1"]
    var adminTeam: String!
    var changedData: String!
    
    @IBOutlet weak var emailDisplay: UILabel!
    @IBOutlet weak var passwordDisplay: UILabel!
    @IBOutlet weak var leagueNameDisplay: UILabel!
    @IBOutlet weak var teamsDisplay: UILabel! //THIS IS BROKE
    @IBOutlet weak var adminsTeam: UILabel!
    
    @IBAction func changeEmail(_ sender: Any) {
        displayMyAlertMessage(title: "Corrections", userMessage: "Enter the new email you want to use.", editedField: emailDisplay)
        email = changedData
        emailDisplay.text = email
    }
    @IBAction func changePassword(_ sender: Any) {
        displayMyAlertMessage(title: "Corrections", userMessage: "Enter the new password you want to use.", editedField: passwordDisplay)
        password = changedData
        passwordDisplay.text = password
    }
    @IBAction func changeLeagueName(_ sender: Any) {
        displayMyAlertMessage(title: "Corrections", userMessage: "Enter the new league name you want to use.", editedField: leagueNameDisplay)
        leagueName = changedData
        leagueNameDisplay.text = leagueName
    }
    @IBAction func adminTeam(_ sender: Any) {
        displayMyAlertMessage(title: "Corrections", userMessage: "Enter the new name of your team.", editedField: adminsTeam)
        adminTeam = changedData
        adminsTeam.text = adminTeam
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailDisplay.text = email
        passwordDisplay.text = password
        leagueNameDisplay.text = leagueName
        teams.removeAll()
        teamsDisplay.text = teams.joined(separator: ", ")
        adminsTeam.text = adminTeam
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAccount() {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                
                self.saveUID()
                //self.autoLoginSegue()
                
            } else {
                
                self.displayMyAlertMessage(title: "Oops!", userMessage: (error?.localizedDescription)!, editedField: self.emailDisplay)
            }
        })
    }
    
    func saveUID() {
        
        let user = FIRAuth.auth()?.currentUser
        let userUID = user?.uid
        
        ref2.child("/\(userUID!)").setValue(adminTeam)
        
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
            }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
}
