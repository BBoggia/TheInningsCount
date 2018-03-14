//
//  TeamCheckTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/13/18.
//  Copyright © 2018 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TeamCheckTableViewController: UITableViewController {

    var ageCheck: Bool!
    var teamCheck: Bool!
    var leagueNum: String!
    var leagueName: String!
    var ageSelected: String!
    var teamSelected: String!
    var usrProgress: Int!
    var tableArray: Array<String>!
    var ref : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        tableArray = []
        checkProgress()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkProgress() {
        
        if self.ageCheck == false {
            self.usrProgress = 0
            self.ageTeamSelection()
        } else if self.teamCheck == false {
            self.teamSelection()
            self.usrProgress = 1
        } else if self.ageCheck && self.teamCheck == true {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func ageTeamSelection() {
        tableArray.removeAll()
        ref?.child("LeagueStats").child(self.leagueNum).child(self.leagueName).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.tableArray.append(snap.key)
                self.tableView.reloadData()
            }
        })
    }
    
    func teamSelection() {
        if self.tableArray != nil {
            self.tableArray.removeAll()
        }
        ref?.child("LeagueStats").child(self.leagueNum).child(self.leagueName).child(ageSelected).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.tableArray.append(snap.key)
                self.tableView.reloadData()
            }
        })
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            
        }
        let cancelAction = UIAlertAction(title: "", style: UIAlertActionStyle.cancel)
        myAlert.addAction(cancelAction)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if usrProgress == 0 {
            ageSelected = tableArray[indexPath.row]
            usrProgress = 1
            teamSelection()
        } else if usrProgress == 1 {
            teamSelected = tableArray[indexPath.row]
            if ageSelected != nil {
                displayMyAlertMessage(title: "Confirm", userMessage: "You have selected:\n\(self.ageSelected) and \(self.teamSelected).\nIs this correct?")
            } else {
                displayMyAlertMessage(title: "Confirm", userMessage: "You have selected:\n\(self.teamSelected)\nIs this correct?")
            }
        }
        return cell
    }
}

