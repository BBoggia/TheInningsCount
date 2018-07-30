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
    
    var user: User!
    var userUID: String!
    var randNum: String!
    var leagueName: String!
    var selectedAge: String!
    var tableList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid
        dataObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        Refs().statRef.child(self.randNum).child(self.leagueName).child(self.selectedAge).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
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
        let currentCell = tableView.cellForRow(at: indexPath!) as UITableViewCell?

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dataEntry") as! b810DataEntryViewController
        vc.age = self.selectedAge
        vc.leagueName = leagueName
        vc.randNum = randNum
        vc.teamName = currentCell?.textLabel?.text as String?
        vc.isAdmin = true
        vc.fromAdminList = true
        navigationController?.pushViewController(vc,animated: true)
    }
    
}
