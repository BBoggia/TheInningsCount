//
//  RenameTeam1TableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/19/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RenameTeam1TableViewController: UITableViewController {
    
    let user = FIRAuth.auth()?.currentUser
    let userUID = FIRAuth.auth()?.currentUser?.uid
    let ref = FIRDatabase.database().reference()
    
    var tablePath: FIRDatabaseReference!
    var convertedArray = [String]()
    var league: String!
    var ageGroup: String!
    var selectedCell: String!
    var alertTextField: String!
    var theSnapshot: FIRDataSnapshot!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("UserData").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.value as! String!
            self.dataObserver()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        
        self.tablePath = self.ref.child("LeagueTeamLists").child(self.league)
        
        self.tablePath.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.convertedArray.append(snap.key)
                self.tableView.reloadData()
            }
            print(self.convertedArray)
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return convertedArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = convertedArray[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedCell = convertedArray[indexPath.row]
        
        let myAlert = UIAlertController(title: "Rename Team", message: "Enter the new name for the team selected.", preferredStyle: UIAlertControllerStyle.alert)
        
        myAlert.addTextField()
        
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            self.alertTextField = myAlert.textFields![0].text
            
            self.ref.child("LeagueTeamLists").child(self.league).observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.ref.child("LeagueTeamLists").child(self.league).child(self.alertTextField).setValue("Team")
                
                self.ref.child("LeagueTeamLists").child(self.league).child(self.selectedCell).removeValue()
                
            })
            
            self.ref.child("LeagueDatabase").child(self.league).observeSingleEvent(of: .value, with: { (snapshot) in
                
                for child in snapshot.children {
                    
                    let snap = child as! FIRDataSnapshot
                    
                    
                    
                    self.ref.child("LeagueDatabase").child(self.league).child(snap.key).child(self.alertTextField).setValue(snapshot.childSnapshot(forPath: snap.key).childSnapshot(forPath: self.selectedCell).value)
                    
                    //self.ref.child("LeagueDatabase").child(self.league).child(snap.key).child(self.selectedCell).removeValue()
                }
            })
            
            self.ref.child("UserData").observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                    let snap = child as! FIRDataSnapshot
                    
                    if snap.childSnapshot(forPath: "League").value as! String! == self.league && snap.childSnapshot(forPath: "Team").value as! String! == self.selectedCell {
                        self.ref.child("UserData").child(snap.key).child("Team").setValue(self.alertTextField)
                    }
                }
            })
            
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
}
