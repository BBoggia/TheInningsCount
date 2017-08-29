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

    var ref : DatabaseReference?
    var ref2 : DatabaseReference?
    let loginRef = ViewController()
    
    var leagueName: String!
    var email: String!
    var password: String!
    var teams = [String]()
    var changedData: String!
    var ageGroups = [String]()
    var randomGenNum: String!
    
    @IBOutlet var yourEmail: UILabel!
    @IBOutlet var yourPassword: UILabel!
    @IBOutlet var yourLeagueName: UILabel!
    @IBOutlet var yourLeagueTeams: UILabel!
    @IBOutlet var yourLeagueAges: UILabel!
    @IBOutlet weak var emailDisplay: UILabel!
    @IBOutlet weak var passwordDisplay: UILabel!
    @IBOutlet weak var leagueNameDisplay: UILabel!
    @IBOutlet weak var teamsDisplay: UILabel!
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
    @IBAction func confirm(_ sender: Any) {
        
        if (leagueNameDisplay.text?.contains("$"))! || (leagueNameDisplay.text?.contains("."))! || (leagueNameDisplay.text?.contains("["))! || (leagueNameDisplay.text?.contains("]"))! || (leagueNameDisplay.text?.contains("#"))! || (leagueNameDisplay.text?.contains("/"))! || (leagueNameDisplay.text?.contains("\\"))!    {
            
            displayMyAlertMessageAlternate(title: "Oops!", userMessage: "Your league name contains one of the following restricted characters!\n\n$, ., [, ], #, /, \\")
            
        } else {
            randomString()
            createAccount()
            autoSignIn()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        ref2 = Database.database().reference().child("UserData")
        
        emailDisplay.text = email
        passwordDisplay.text = password
        leagueNameDisplay.text = leagueName
        teamsDisplay.text = teams.joined(separator: ", ")
        leagueAges.text = ageGroups.joined(separator: ", ")
        
        /*if UIDevice.current.userInterfaceIdiom == .pad {
            yourEmail.font = UIFont(name: yourEmail.font.fontName, size: 24)
            yourPassword.font = yourEmail.font
            yourLeagueName.font = yourEmail.font
            yourLeagueAges.font = yourEmail.font
            yourTeam.font = yourEmail.font
            emailDisplay.font = UIFont(name: emailDisplay.font.fontName, size: 24)
            passwordDisplay.font = UIFont(name: passwordDisplay.font.fontName, size: 24)
            leagueNameDisplay.font = UIFont(name: leagueNameDisplay.font.fontName, size: 24)
            teamsDisplay.font = UIFont(name: teamsDisplay.font.fontName, size: 24)
            adminsTeam.font = UIFont(name: adminsTeam.font.fontName, size: 24)
            leagueAges.font = UIFont(name: leagueAges.font.fontName, size: 24)
        }*/

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createAccount() {
        
        Auth.auth().createUser(withEmail: emailDisplay.text!, password: passwordDisplay.text!, completion: { (user, error) in
            if error == nil {
                self.autoSignIn()
                self.saveUID()
                    
                for age in self.ageGroups {
                    for team in self.teams {
                        self.ref?.child("LeagueStats").child(self.randomGenNum).child(self.leagueNameDisplay.text!).child(age).child(team).child("Long Date").setValue(["Date" as NSString! : "Date" as NSString!, "Stat" as NSString! : "Player Number | Innings Pitched" as NSString!])
                        self.ref?.child("LeagueData").child(self.randomGenNum).child("Info").child(age).child(team).child("Coaches").child("UID").setValue("Email")
                    }
                }
                
                self.ref?.child("LeagueData").child(self.randomGenNum).child("LeagueName").setValue(self.leagueName)
                self.ref?.child("LeagueData").child(self.randomGenNum).child("Messages").childByAutoId().setValue(["Message":"Important announcements from the league Administraitor will be displayed here.", "Date":"Date of Post"])
                    
                let myAlert1 = UIAlertController(title: "IMPORTANT!", message: "This 5 digit code is needed by your coaches when they create an account to be able to use the app. Write it down or it has been copied to your clipboard. \n|\n\(self.randomGenNum!)", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
                        UIPasteboard.general.string = self.randomGenNum!
                        
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                        
                    self.performSegue(withIdentifier: "fromCL", sender: nil)
                }
                myAlert1.addAction(okAction)
                self.present(myAlert1, animated: true, completion: nil)
            } else {
                self.displayMyAlertMessageAlternate(title: "Oops!", userMessage: (error?.localizedDescription)!)
            }
        })
    }
    
    func saveUID() {
        
        let user = Auth.auth().currentUser
        let userUID = user?.uid
        
        ref2?.child("/\(userUID!)").child("Team").setValue("League Administrator")
        ref2?.child("/\(userUID!)").child("League").child("Name").setValue(leagueNameDisplay.text!)
        ref2?.child("/\(userUID!)").child("League").child("RandomNumber").setValue(randomGenNum)
        ref2?.child("/\(userUID!)").child("status").setValue("admin")
        
        print(userUID!)
    }
    
    func autoSignIn() {
        Auth.auth().signIn(withEmail: self.emailDisplay.text!, password: self.passwordDisplay.text!, completion: {
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
        self.checkRandomString()
    }
    
    func checkRandomString() {
        ref2?.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if self.randomGenNum == snap.key {
                    self.randomString()
                } else {
                    
                }
            }
        })
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
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
}
