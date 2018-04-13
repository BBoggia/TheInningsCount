//
//  AdminDataEntryAgeTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/23/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AdminDataEntryAgeTableViewController: UITableViewController {
    
    var ref : DatabaseReference?
    var user: User!
    var userUID: String!
    
    var randNum: String!
    var leagueName: String!
    
    var tableList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid
        
        ref?.child("UserData").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.leagueName = snapshot.childSnapshot(forPath: "Name").value as! String?
            self.randNum = snapshot.childSnapshot(forPath: "RandomNumber").value as! String?
            self.dataObserver()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        ref?.child("LeagueStats").child(self.randNum).child(leagueName).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.tableList.append(snap.key)
                print(self.tableList)
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
        let currentCell = tableView.cellForRow(at: indexPath!) as UITableViewCell?
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "adminTeamSelect") as! AdminDataEntryTeamTableViewController
        vc.selectedAge = currentCell?.textLabel?.text as String?
        navigationController?.pushViewController(vc,animated: true)
    }

}
