//
//  AdminDataEntryTeamTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/23/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AdminDataEntryTeamTableViewController: UITableViewController {
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    var userUID = FIRAuth.auth()?.currentUser?.uid as String!
    
    var randNum: String!
    var leagueName: String!
    var selectedAge: String!
    
    var tableList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("UserData").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.leagueName = snapshot.childSnapshot(forPath: "Name").value as! String!
            self.randNum = snapshot.childSnapshot(forPath: "RandomNumber").value as! String!
            self.dataObserver()
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        ref.child("LeagueStats").child(self.randNum).child(self.leagueName).child(self.selectedAge).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.tableList.append(snap.key)
                self.tableView.reloadData()
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = tableList[indexPath.row]
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dataEntry") as! b810DataEntryViewController
        vc.age = self.selectedAge
        vc.teamName = currentCell?.textLabel?.text as String!
        vc.adminStop = true
        navigationController?.pushViewController(vc,animated: true)
    }
    
}