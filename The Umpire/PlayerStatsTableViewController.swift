//
//  PlayerStatsTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 1/4/19.
//  Copyright © 2019 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PlayerStatsTableViewController: UITableViewController {
    
    var userUID: String!
    var stats: [Stats]! = []
    var age: String!
    var league: String!
    var team: String!
    var randNum: String!
    var adminStatus: Bool!
    var coachDiv, coachTeam: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        userUID = Auth.auth().currentUser?.uid as String?
        dataObserver()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func dataObserver() {
        Refs().statRef.child(self.randNum).child(self.league).child(self.age).child(self.team).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                var tmp = Stats()
                tmp.player = (snap.childSnapshot(forPath: "Player").value as! String?)!
                tmp.inning = (snap.childSnapshot(forPath: "Innings").value as! String?)!
                tmp.date = (snap.childSnapshot(forPath: "Date").value as! String?)!
                tmp.coach = (snap.childSnapshot(forPath: "Coach").value as! String?)!
                tmp.id = (snap.childSnapshot(forPath: "ID").value as! String?)!
                self.stats.append(tmp)
                self.tableView.reloadData()
            }
            self.stats.reverse()
            if !(self.stats.count <= 1) {
                self.stats.removeFirst()
            }
            self.tableView.reloadData()
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PlayerStatsTableViewCell
        
        cell.statLbl.text = stats[indexPath.row].player + " | " + stats[indexPath.row].inning
        cell.coach.text = stats[indexPath.row].coach
        cell.dateLbl.text = stats[indexPath.row].date
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if adminStatus == true || coachDiv == age && coachTeam == team {
            var tmpList = stats
            if stats.count == 1 && stats[0].id == "0" {
                displayAlert(title: "Oops!", message: "You cannot remove the last item from the list.")
            } else {
                if editingStyle == .delete {
                    Refs().statRef.child(randNum).child(league).child(age).child(team).observeSingleEvent(of: .value) { (snapshot) in
                        for child in snapshot.children {
                            let snap = child as! DataSnapshot
                            if snap.childSnapshot(forPath: "ID").value as? String == tmpList![indexPath.row].id  {
                                Refs().statRef.child(self.randNum).child(self.league).child(self.age).child(self.team).child(snap.key).removeValue()
                                self.stats.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                break
                            }
                        }
                    }
                }
            }
        } else {
            displayAlert(title: "Oops!", message: "Only admins and coaches of this team can remove entries.")
        }
    }
}

class PlayerStatsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var statLbl: UILabel!
    @IBOutlet weak var coach: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
