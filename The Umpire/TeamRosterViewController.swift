//
//  TeamRosterViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/7/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TeamRosterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref = FIRDatabase.database().reference()
    
    var teamName: String!
    var leagueName: String!
    var rosterList = [String]()
    var userUID = FIRAuth.auth()?.currentUser?.uid as String!

    @IBOutlet weak var teamRosterTable: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let teamNameRef = ref.child("User Data").child(userUID!)
        teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.teamName = snapshot.childSnapshot(forPath: "Team").value as! String!
            self.leagueName = snapshot.childSnapshot(forPath: "League").value as! String!
            self.navBar.title = self.leagueName
            self.titleLabel.text = "\(self.teamName!) Team Roster"
            self.populateArray()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateArray() {
        self.ref.child("LeagueTeamLists").child(leagueName).child(teamName).child("Roster").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 1 {
                
                for child in snapshot.children {
                    let snap = child as! FIRDataSnapshot
                    self.rosterList.append("Player Number: \(snap.key)")
                    print(self.rosterList)
                    print(snap.key)
                    self.teamRosterTable.reloadData()
                }
            } else {
                self.rosterList.append("You need to add players to you roster to see them here!")
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rosterList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = teamRosterTable.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = rosterList[indexPath.row]
        
        return cell!
    }
    
}
