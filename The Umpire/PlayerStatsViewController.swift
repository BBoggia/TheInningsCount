//
//  PlayerStatsViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/9/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PlayerStatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var playerDataTable: UITableView!
    
    let ref = FIRDatabase.database().reference()
    var userUID = FIRAuth.auth()?.currentUser?.uid as String!
    var playerStatsList = [String]()
    var age: String!
    var league: String!
    var team: String!
    var randNum: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("UserData").child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
            self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
            self.dataObserver()
        })
        
        self.playerDataTable.delegate = self
        self.playerDataTable.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dataObserver() {
        ref.child("LeagueStats").child(self.randNum).child(self.league).child(self.age).child(self.team).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.playerStatsList.append(snap.value as! String!)
                print(self.playerStatsList)
                self.playerDataTable.reloadData()
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerStatsList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerDataTable.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = playerStatsList[indexPath.row]
        
        return cell!
    }
}
