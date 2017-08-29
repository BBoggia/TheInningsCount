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

class AddRemoveTeamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User!
    var userUID: String!
    var ref : DatabaseReference?
    
    @IBOutlet weak var tableView: UITableView!
    
    var tablePath: DatabaseReference!
    var convertedArray = [String]()
    var league: String!
    var ageGroup: String!
    var selectedCell: String!
    var alertTextField: String!
    var theSnapshot: DataSnapshot!
    var randNum: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid
        
        ref?.child("UserData").child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
            self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
            self.dataObserver()
        })
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        
        self.tablePath = self.ref?.child("LeagueStats").child(self.randNum).child(self.league)
        
        self.tablePath.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.convertedArray.append(snap.key)
                self.tableView.reloadData()
            }
            print(self.convertedArray)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return convertedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = convertedArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
        
        ageGroup = currentCell?.textLabel?.text
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "arvc2") as! AddRemoveTeamViewController2
        vc.ageGroup = self.ageGroup
        navigationController?.pushViewController(vc,animated: true)
    }
}

