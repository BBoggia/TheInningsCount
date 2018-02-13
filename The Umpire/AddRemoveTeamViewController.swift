//
//  AddRemoveTeamViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 5/17/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AddRemoveTeamTableViewController: UITableViewController {
    
    var user: User!
    var userUID: String!
    var ref : DatabaseReference?
    
    var tablePath: DatabaseReference!
    var convertedArray = [String]()
    var league: String!
    var team: String!
    var ageGroup: String!
    var selectedCell: String!
    var alertTextField: String!
    var theSnapshot: DataSnapshot!
    var randNum: String!
    @IBAction func addTeam(_ sender: Any) {
        
        let myAlert = UIAlertController(title: "Add Team", message: "Enter the name of the team you want to add to this division.", preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addTextField()
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            self.alertTextField = myAlert.textFields![0].text
            self.tablePath.observeSingleEvent(of: .value, with: { (snapshot) in
                self.tablePath.child(self.alertTextField).setValue("placeholder")
            })
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AddRemoveAgeTableViewController.longPress(_:)))
        longPressGesture.minimumPressDuration = 1.75
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.tableView.addGestureRecognizer(longPressGesture)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        
        self.tablePath.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.convertedArray.append(snap.key)
                self.tableView.reloadData()
            }
            print(self.convertedArray)
        })
    }
    
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let myAlert = UIAlertController(title: "Rename Division", message: "Enter the name you want to change \(self.convertedArray[indexPath.row]) to.", preferredStyle: UIAlertControllerStyle.alert)
                myAlert.addTextField()
                let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
                    self.alertTextField = myAlert.textFields![0].text
                    
                    self.ref?.child("LeagueStats").child(self.randNum).child(self.league).child(self.ageGroup).observeSingleEvent(of: .value, with: { (snapshot) in
                        self.ref?.child("LeagueStats").child(self.randNum).child(self.league).child(self.ageGroup).child(self.alertTextField).setValue(snapshot.childSnapshot(forPath: self.convertedArray[indexPath.row]))
                        self.ref?.child("LeagueStats").child(self.randNum).child(self.league).child(self.ageGroup).child(self.convertedArray[indexPath.row]).removeValue()
                    })
                    
                    self.ref?.child("UserData").observeSingleEvent(of: .value, with: { (snapshot) in
                        for child in snapshot.children {
                            let snap = child as! DataSnapshot
                            
                            if snap.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String! == self.league && snap.childSnapshot(forPath: "Team").value as! String! == self.convertedArray[indexPath.row] && snap.childSnapshot(forPath: "AgeGroup").value as! String! == self.ageGroup {
                                self.ref?.child("UserData").child(snap.key).child("Team").setValue(self.alertTextField)
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
    }
    
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
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
        
        selectedCell = currentCell?.textLabel?.text
    }
}

