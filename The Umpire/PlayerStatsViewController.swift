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
    
    var ref : DatabaseReference?
    var userUID: String!
    var playerStatsList = [String]()
    var dateList = [String]()
    var age: String!
    var league: String!
    var team: String!
    var randNum: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        userUID = Auth.auth().currentUser?.uid as String?
        
        ref?.child("UserData").child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String?
            self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String?
            self.dataObserver()
        })
        
        self.playerDataTable.delegate = self
        self.playerDataTable.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dataObserver() {
       
        ref?.child("LeagueStats").child(self.randNum).child(self.league).child(self.age).child(self.team).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.playerStatsList.append((snap.childSnapshot(forPath: "Stat").value as! String?)!)
                self.dateList.append((snap.childSnapshot(forPath: "Date").value as! String?)!)
                self.playerDataTable.reloadData()
            }
            self.playerStatsList.reverse()
            self.dateList.reverse()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerStatsList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerDataTable.dequeueReusableCell(withIdentifier: "cell") as! PlayerStatsTableViewCell
        
        cell.statLbl.text = playerStatsList[indexPath.row]
        cell.dateLbl.text = dateList[indexPath.row]
        
        return cell
    }
}

class PlayerStatsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var statLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
