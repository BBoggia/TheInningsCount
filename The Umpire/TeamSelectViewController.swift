//
//  TeamSelectViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/8/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class TeamSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var teamListTable: UITableView!
    
    let ref = FIRDatabase.database().reference()
    var userUID = FIRAuth.auth()?.currentUser?.uid as String!
    var teamList = [String]()
    var teamToPass: String!
    var age: String!
    var league:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("User Data").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.value as! String!
            self.dataObserver()
        })
        
        self.teamListTable.delegate = self
        self.teamListTable.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dataObserver() {
        ref.child("LeagueTeamLists").child(league).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.teamList.append(snap.key)
                print(self.teamList)
                print(snap.key)
                self.teamListTable.reloadData()
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
        let cell = teamListTable.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = teamList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = teamListTable.indexPathForSelectedRow
        let currentCell = teamListTable.cellForRow(at: indexPath!) as UITableViewCell!
        
        teamToPass = currentCell?.textLabel?.text
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "playerStats") as! PlayerStatsViewController
        vc.age = age
        vc.team = teamToPass
        navigationController?.pushViewController(vc,animated: true)
    }
}
