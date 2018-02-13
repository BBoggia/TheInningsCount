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
    var user = Auth.auth().currentUser
    var userUID: String!
    var leagueNum = ""
    
    var teamName: String!
    var leagueName: String!
    var isAdmin = false

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
        
        performSegue(withIdentifier: "logout", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        userUID = Auth.auth().currentUser?.uid as String!
        
        let teamNameRef = ref?.child("UserData").child(userUID!)
        teamNameRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childSnapshot(forPath: "status").value as! String! == "admin" {
                self.isAdmin = true
            }
            self.leagueName = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
            self.leagueNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
            
           /* var verifyAge = false
            var verifyTeam = false
            if self.isAdmin != true {
                self.ref?.child("LeagueStats").child(self.leagueNum).child(self.leagueName).observeSingleEvent(of: .value, with: { (snap) in
                    for i in snap.children {
                        let age = i as! DataSnapshot
                        if snapshot.childSnapshot(forPath: "AgeGroup").value as? String! == age.value as? String {
                            verifyAge = true
                            for j in snap.childSnapshot(forPath: age.key).children {
                                let team = j as! DataSnapshot
                                if snapshot.childSnapshot(forPath: "Team").value as? String! == team.value as? String {
                                    verifyTeam = true
                                    break
                                }
                            }
                        }
                        if verifyAge && verifyTeam == true {
                            break
                        }
                    }
                    if verifyAge || verifyTeam == false {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "ageTeamVerify") as! AgeTeamCheckTableViewController
                        vc.ageCheck = verifyAge
                        vc.teamCheck = verifyTeam
                        vc.leagueName = self.leagueName
                        vc.leagueNum = self.leagueNum
                        self.navigationController?.pushViewController(vc,animated: true)
                    }
                })
            }*/
            self.navBar.title = self.leagueName
            self.titleLabel.text = self.teamName
        })
        
        if isAdmin == true {
            
            navBar.rightBarButtonItem = UIBarButtonItem(title: "Admin", style: .plain, target: self, action: #selector(adminSegue))
            
        }
        
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
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }

}
