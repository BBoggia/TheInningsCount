//
//  SignupTeamSelectViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/29/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SignupTeamSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var teamTableView: UITableView!
    
    var teamList = [String]()
    var team: String!
    var age: String!
    var leagueCode: String!
    var leagueName: String!
    var usrEmail: String!
    var usrPass: String!
    var firstName: String!
    var lastName: String!
    
    let user = Auth.auth().currentUser
    var userUID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userUID = Auth.auth().currentUser?.uid
        
        populateView()
        
        teamTableView.delegate = self
        teamTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateView() {
        Refs().statRef.child(self.leagueCode).child(self.leagueName).child(age).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.teamList.append(snap.key)
                print(self.teamList)
                self.teamTableView.reloadData()
            }
        })
    }
    
    func displayMyAlertMessage(title:String, message:String) {
        let myAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            action in
            self.createAccount()
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            self.performSegue(withIdentifier: "coachToNav", sender: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func saveUID() {
        
        let user = Auth.auth().currentUser
        let userUID = user?.uid
        
        Refs().usrRef.child("/\(userUID!)").child("AgeGroup").setValue(age)
        Refs().usrRef.child("/\(userUID!)").child("League").child("Name").setValue(leagueName)
        Refs().usrRef.child("/\(userUID!)").child("League").child("RandomNumber").setValue(leagueCode)
        Refs().usrRef.child("/\(userUID!)").child("IsAdmin").setValue(false)
        Refs().usrRef.child("/\(userUID!)").child("Team").setValue(team)
        Refs().dataRef.child(leagueCode).child("CoachInfo").child("/\(userUID!)").child("Email").setValue(usrEmail)
        Refs().dataRef.child(leagueCode).child("CoachInfo").child("/\(userUID!)").child("FirstName").setValue(firstName)
        Refs().dataRef.child(leagueCode).child("CoachInfo").child("/\(userUID!)").child("LastName").setValue(lastName)
        Refs().dataRef.child(leagueCode).child("CoachInfo").child("/\(userUID!)").child("Division").setValue(age)
        Refs().dataRef.child(leagueCode).child("CoachInfo").child("/\(userUID!)").child("Team").setValue(team)
        Refs().dataRef.child(leagueCode).child("CoachInfo").child("/\(userUID!)").child("IsAdmin").setValue(false)
    }
    
    func createAccount() {
        
        Refs().dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !(self.leagueCode.isEmpty) && snapshot.hasChild(self.leagueCode) {
                if !(self.usrEmail.contains("@")) || !(self.usrEmail.contains(".")) {
                    
                    self.displayMyAlertMessage(title: "Oops!", message: "It seems your email is missing something.")
                } else {
                    
                    Auth.auth().createUser(withEmail: self.usrEmail, password: self.usrPass, completion: { (user, error) in
                        if error == nil {
                            
                            self.autoSignIn()
                        } else {
                            
                            let alertController = UIAlertController(title: "Oops!", message: "That code doesn't match any available Leagues.", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
                }
            } else {
                self.displayMyAlertMessage(title: "Oops!", message: "The league code you entered is invalid!")
            }
        })
    }
    
    func autoSignIn() {
        Auth.auth().signIn(withEmail: self.usrEmail, password: self.usrPass, completion: {
            (user, error) in
            
            if error == nil {
                self.saveUID()
            }
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = teamTableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = teamList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = teamTableView.indexPathForSelectedRow
        let currentCell = teamTableView.cellForRow(at: indexPath!) as UITableViewCell?
        team = currentCell?.textLabel?.text
        
        displayMyAlertMessage(title: "Confirm", message: "Is this correct?\nDivision: \(self.age!)\nTeam: \(self.team!)")
    }
}
