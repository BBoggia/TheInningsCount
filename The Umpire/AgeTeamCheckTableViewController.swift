//
//  AgeTeamCheckTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 2/6/18.
//  Copyright © 2018 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AgeTeamCheckTableViewController: UITableViewController {
    
    var ageCheck: Bool!
    var teamCheck: Bool!
    var leagueNum: String!
    var leagueName: String!
    var ageSelected: String!
    var teamSelected: String!
    var usrUID: String!
    var usrProgress: Int!
    var tableArray: Array<String>!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableArray = []
        checkProgress()
        anotherAlert(title: "Oops!", message: "It looks like the division or team you were assigned to was renamed or removed. If you see yours in the list press continue and select it now, otherwise select wait and ask your league admin to add it back.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkProgress() {
        
        if self.ageCheck == false {
            self.usrProgress = 0
            self.ageTeamSelection()
        } else if self.teamCheck == false {
            Refs().dataRef.child(self.usrUID).observeSingleEvent(of: .value, with: { (snapshot) in
                self.ageSelected = snapshot.childSnapshot(forPath: "AgeGroup").value as? String
                self.teamSelection()
                self.usrProgress = 1
            })
        } else if self.ageCheck && self.teamCheck == true {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func ageTeamSelection() {
        tableArray.removeAll()
        Refs().statRef.child(self.leagueNum).child(self.leagueName).observeSingleEvent(of: .value, with: { (snapshot) in
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
        Refs().statRef.child(self.leagueNum).child(self.leagueName).child(ageSelected).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.tableArray.append(snap.key)
                self.tableView.reloadData()
            }
        })
    }
    
    func displayMyAlertMessage(title:String, userMessage:String) {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            Refs().usrRef.child(self.usrUID).child("AgeGroup").setValue(self.ageSelected)
            Refs().usrRef.child(self.usrUID).child("Team").setValue(self.teamSelected)
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Restart", style: UIAlertActionStyle.cancel) { action in
            self.checkProgress()
        }
        myAlert.addAction(cancelAction)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func anotherAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Continue", style: .default, handler: nil)
        let wait = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
            } catch _ as NSError {}
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        alert.addAction(wait)
        self.present(alert, animated: true, completion: nil)
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
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if usrProgress == 0 {
            ageSelected = tableArray[indexPath.row]
            usrProgress = 1
            teamSelection()
        } else if usrProgress == 1 {
            teamSelected = tableArray[indexPath.row]
            if ageSelected != nil {
                displayMyAlertMessage(title: "Confirm", userMessage: "You have selected:\n\(self.ageSelected!) and \(self.teamSelected!).\nIs this correct?")
            } else {
                displayMyAlertMessage(title: "Confirm", userMessage: "You have selected:\n\(self.teamSelected!)\nIs this correct?")
            }
        }
    }
}
