//
//  mainHubViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/6/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class mainHubViewController: UIViewController {
    
    var ref : DatabaseReference?
    let user = Auth.auth().currentUser
    var userUID: String!
    var leagueNum = ""
    
    var team: String!
    var Division: String!
    var leagueName: String!
    var isAdmin = false
    var verifyAge = false
    var verifyTeam = false

    @IBAction func roster(_ sender: Any) {
        displayMyAlertMessage(title: "Comming Soon", userMessage: "This feature is in development and will be released soon.")
    }
    @IBOutlet var inningsBtn: UIButton!
    @IBOutlet var dataBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coachesHub: UILabel!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBAction func logOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        //performSegue(withIdentifier: "logout", sender: nil)
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        userUID = Auth.auth().currentUser?.uid as String!
        
        let teamNameRef = ref?.child("UserData").child(userUID!)
        teamNameRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childSnapshot(forPath: "status").value as! String! == "admin" {
                self.isAdmin = true
                self.navBar.rightBarButtonItem = UIBarButtonItem(title: "Admin", style: .plain, target: self, action: #selector(self.adminSegue))
                self.navBar.title = "League Admin"
            } else {
                self.Division = snapshot.childSnapshot(forPath: "AgeGroup").value as! String!
                self.team = snapshot.childSnapshot(forPath: "Team").value as! String!
                self.navBar.title = self.leagueName
                self.titleLabel.text = self.team
            }
            self.leagueName = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
            self.leagueNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
            self.verifyAccDetails()
        })
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            inningsBtn.heightAnchor.constraint(equalToConstant: 180).isActive = true
            titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 38)
            coachesHub.font = UIFont(name: coachesHub.font.fontName, size: 42)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func adminSegue() {
        performSegue(withIdentifier: "toAdmin", sender: nil)
    }
    
    func verifyAccDetails() {
        
        if self.isAdmin == false {
            let teamNameRef = ref?.child("UserData").child(userUID!)
            teamNameRef?.observeSingleEvent(of: .value, with: { (snapshot) in
                self.ref?.child("LeagueStats").child(self.leagueNum).child(self.leagueName).observeSingleEvent(of: .value, with: { (snap) in
                    let childCount = snap.childrenCount
                    var loopCount = 0
                    for i in snap.children {
                        let div = i as! DataSnapshot
                        if self.Division == div.key {
                            self.verifyAge = true
                            for j in snap.childSnapshot(forPath: div.key).children {
                                let team = j as! DataSnapshot
                                if self.team == team.key {
                                    self.verifyTeam = true
                                    break
                                }
                            }
                        }
                        loopCount += 1
                        if self.verifyAge && self.verifyTeam == true {
                            break
                        }
                        if loopCount == childCount {self.segueCoach()}
                    }
                })
            })
        }
    }
    
    func segueCoach() {
        
        if self.verifyAge || self.verifyTeam == false {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "verifyAcc") as! AgeTeamCheckTableViewController
            vc.ageCheck = self.verifyAge as Bool
            vc.teamCheck = self.verifyTeam as Bool
            vc.leagueName = self.leagueName as String
            vc.leagueNum = self.leagueNum as String
            vc.usrUID = self.userUID as String
            self.navigationController?.pushViewController(vc,animated: true)
        }
    }
    
    func displayMyAlertMessage(title:String, userMessage:String) {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }

}
