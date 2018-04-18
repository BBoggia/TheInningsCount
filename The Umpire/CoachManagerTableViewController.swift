//
//  CoachManagerTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/9/18.
//  Copyright © 2018 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class CoachManagerTableViewController: UITableViewController {
    
    var user: User!
    var leagueCode: String!
    var coachList = [Coach?]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        dataObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        
        Refs().dataRef.child(leagueCode).child("CoachInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                var coach = Coach()
                coach.div = snap.childSnapshot(forPath: "Division").value as! String
                coach.team = snap.childSnapshot(forPath: "Team").value as! String
                coach.email = snap.childSnapshot(forPath: "Email").value as! String
                coach.firstName = snap.childSnapshot(forPath: "FirstName").value as! String
                coach.lastName = snap.childSnapshot(forPath: "LastName").value as! String
                coach.isAdmin = snap.childSnapshot(forPath: "IsAdmin").value as! Bool
                self.coachList.append(coach)
                self.tableView.reloadData()
            }
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return coachList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CoachTableViewCell
        
        cell.firstLastName.text = (coachList[indexPath.row]?.firstName)! + " " + (coachList[indexPath.row]?.lastName)!
        cell.email.text = coachList[indexPath.row]?.email
        if coachList[indexPath.row]?.isAdmin == true {
            cell.isAdmin.text = "A"
            cell.div.text = "No Division"
            cell.team.text = "No Team"
        } else {
            cell.isAdmin.text = "C"
            cell.div.text = coachList[indexPath.row]?.div
            cell.team.text = coachList[indexPath.row]?.team
        }
        return cell
    }
}

class CoachTableViewCell: UITableViewCell {
    @IBOutlet weak var firstLastName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var div: UILabel!
    @IBOutlet weak var team: UILabel!
    @IBOutlet weak var isAdmin: UILabel!
    
}

struct Coach {
    
    var firstName, lastName, email, div, team: String!
    var isAdmin: Bool!
}
