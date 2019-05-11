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
    @IBOutlet weak var titleLbl: UILabel!
    
    var teamList = [String]()
    var team: String!
    var division: String!
    var leagueCode: String!
    var leagueName: String!
    var usrEmail: String!
    var usrPass: String!
    var usrUID: String!
    var firstName: String!
    var lastName: String!
    var alreadyHaveAccCheck = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateView()
        teamTableView.delegate = self
        teamTableView.dataSource = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleLbl.font = UIFont.boldSystemFont(ofSize: 66)
            titleLbl.frame = CGRect(x: titleLbl.frame.minX, y: titleLbl.frame.minY, width: titleLbl.frame.width, height: titleLbl.frame.height * 2)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateView() {
        Refs().statRef.child(self.leagueCode).child(self.leagueName).child(division).observeSingleEvent(of: .value, with: { (snapshot) in
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
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { action in
            if self.alreadyHaveAccCheck == true {
                Refs().dataRef.child(self.leagueCode).child("Requests").child(userAcc.uid).setValue(["DateRequested" : NSDate().userSafeDate, "Date Accepted" : "","Email" : userAcc.email, "Division" : self.division, "Team" : self.team, "RequestStatus" : false, "Name":"\(userAcc.firstName + " " + userAcc.lastName)"])
                Refs().usrRef.child(userAcc.uid).child("Requests").child(self.leagueCode).setValue(["DateRequested" : NSDate().userSafeDate, "DateAccepted" : "", "LeagueName" : self.leagueName, "Division" : self.division, "Team" : self.team, "RequestStatus" : false])
                self.performSegue(withIdentifier: "fromJoinRequest", sender: nil)
                self.displayAlert(title: "Success!", message: "Your request has been send and is waiting for an admin to approve it.")
            } else {
                self.createAccount()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func saveUID() {
        Refs().dataRef.child(leagueCode).child("Requests").child(usrUID).setValue(["DateRequested" : NSDate().userSafeDate, "Date Accepted" : "","Email" : usrEmail, "Division" : division, "Team" : team, "RequestStatus" : false, "Name":"\(self.firstName + " " + self.lastName)"])
        Refs().usrRef.child(usrUID).setValue(["FirstName" : "\(self.firstName!)", "LastName" : "\(self.lastName!)", "UID" : usrUID, "Email" : usrEmail])
        Refs().usrRef.child(usrUID).child("Requests").child(leagueCode).setValue(["DateRequested" : NSDate().userSafeDate, "DateAccepted" : "", "LeagueName" : leagueName, "Division" : division, "Team" : team, "RequestStatus" : false])
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.navigationController?.popToRootViewController(animated: true)
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
                self.usrUID = user?.uid
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
        
        displayMyAlertMessage(title: "Confirm", message: "Is this correct?\nDivision: \(self.division!)\nTeam: \(self.team!)")
    }
}
