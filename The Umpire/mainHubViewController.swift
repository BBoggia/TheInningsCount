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
        displayAlert(title: "Comming Soon", message: "This feature is in development and will be released soon.")
    }
    @IBAction func enterData(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dataEntry") as! b810DataEntryViewController
        vc.age = Division
        vc.teamName = team
        vc.isAdmin = isAdmin
        vc.leagueName = leagueName
        vc.randNum = leagueNum
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewDataBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ageSelect") as! TeamDataSegueViewController
        vc.league = leagueName
        vc.randNum = leagueNum
        vc.adminStatus = isAdmin
        vc.coachDiv = Division
        vc.coachTeam = team
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewAnnouncements(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "leagueAnnouncements") as! ViewLeagueAnnouncementsViewController
        vc.league = leagueName
        vc.randNum = leagueNum
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBOutlet weak var inputBtn: UIButton!
    @IBOutlet weak var announcements: UIButton!
    @IBOutlet var dataBtn: UIButton!
    @IBOutlet weak var coachesHub: UILabel!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var backgroundLbl: UILabel!
    
    //For iPad size changes
    @IBOutlet weak var holderView: UIView!
    @IBOutlet var displayLbls: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userUID = Auth.auth().currentUser?.uid as String?
        Refs().usrRef.child(userUID!).child("Leagues").child(leagueNum).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childSnapshot(forPath: "AdminStatus").value as! Bool? == true {
                self.isAdmin = true
                self.navBar.rightBarButtonItem = UIBarButtonItem(title: "Admin", style: .plain, target: self, action: #selector(self.adminSegue))
                self.navBar.title = "League Admin"
                for i in self.displayLbls {
                    if i.tag == 1 {
                        i.text = self.leagueName
                    }
                    if i.tag == 3 {
                        i.text = "League Admin"
                    }
                    if i.tag == 5 {
                        i.text = "n/a"
                    }
                }
            } else {
                self.Division = snapshot.childSnapshot(forPath: "Division").value as! String?
                self.team = snapshot.childSnapshot(forPath: "Team").value as! String?
                self.navBar.title = self.leagueName
                for i in self.displayLbls {
                    if i.tag == 1 {
                        i.text = self.leagueName
                    }
                    if i.tag == 3 {
                        i.text = self.Division
                    }
                    if i.tag == 5 {
                        i.text = self.team
                    }
                }
            }
            self.verifyAccDetails()
            /*if UIDevice.current.userInterfaceIdiom == .pad {
                self.inputBtn.titleLabel?.font = .boldSystemFont(ofSize: 38)
                self.announcements.titleLabel?.font = .boldSystemFont(ofSize: 38)
                self.dataBtn.titleLabel?.font = .boldSystemFont(ofSize: 38)
            }*/
        })
        
        backgroundLbl.layer.masksToBounds = true
        backgroundLbl.layer.cornerRadius = 10
        
        UserDefaults.standard.set(["league":leagueName, "number":leagueNum, "division":Division, "team":team], forKey: userAcc.uid)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            inputBtn.heightAnchor.constraint(equalToConstant: 140).isActive = true
            coachesHub.font = UIFont(name: coachesHub.font.fontName, size: 64)
            coachesHub.heightAnchor.constraint(equalToConstant: 160).isActive = true
            holderView.heightAnchor.constraint(equalToConstant: 305).isActive = true
            for i in displayLbls {
                if i.tag == 0 || i.tag == 2 || i.tag == 4 {
                    i.font = UIFont(name: i.font.fontName, size: 34)
                } else if i.tag == 1 || i.tag == 3 || i.tag == 5 {
                    i.font = UIFont(name: i.font.fontName, size: 32)
                }
            }
            for i in buttons {
                i.titleLabel?.font = UIFont(name: (i.titleLabel?.font.fontName)!, size: 38)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func adminSegue() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "adminHub") as! AdminHubViewController
        vc.leagueName = self.leagueName
        vc.leagueCode = self.leagueNum
        vc.user = self.user
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
    func verifyAccDetails() {
        if self.isAdmin == false {
            Refs().usrRef.child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                Refs().statRef.child(self.leagueNum).child(self.leagueName).observeSingleEvent(of: .value, with: { (snap) in
                    let divCount = snap.childrenCount
                    var teamCount: Int!
                    var divLoopCount = 0
                    var teamLoopCount = 0
                    for i in snap.children {
                        let div = i as! DataSnapshot
                        if self.Division == div.key {
                            teamCount = Int(snap.childSnapshot(forPath: div.key).childrenCount)
                            self.verifyAge = true
                            for j in snap.childSnapshot(forPath: div.key).children {
                                let team = j as! DataSnapshot
                                if self.team == team.key {
                                    self.verifyTeam = true
                                    break
                                }
                                teamLoopCount += 1
                            }
                        }
                        divLoopCount += 1
                        if self.verifyAge == true && self.verifyTeam == true {
                            break
                        }
                        if divLoopCount == divCount || teamCount != nil && teamCount == teamLoopCount {self.segueCoach()}
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
}
