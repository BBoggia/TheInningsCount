//
//  ViewLeagueAnnouncementsViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/23/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewLeagueAnnouncementsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var clientTable: UITableView!
    
    let user = FIRAuth.auth()?.currentUser
    let userUID = FIRAuth.auth()?.currentUser?.uid
    let ref = FIRDatabase.database().reference()
    var msgRef: FIRDatabaseReference!
    private var newMessageRefHandle: FIRDatabaseHandle?
    
    var league: String!
    var randNum: String!
    var messages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clientTable.delegate = self
        clientTable.dataSource = self
        
        ref.child("UserData").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.childSnapshot(forPath: "Name").value as! String!
            self.randNum = snapshot.childSnapshot(forPath: "RandomNumber").value as! String!
            self.msgRef = self.ref.child("LeagueData").child(self.randNum).child("Messages")
            self.dataObserver()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        
        let messageQuery = self.msgRef.queryLimited(toLast:15)
        
        self.newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.messages.append(snap.value as! String!)
                print(self.messages)
                self.clientTable.reloadData()
            }
            self.clientTable.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = clientTable.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = messages[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = clientTable.indexPathForSelectedRow
        let currentCell = clientTable.cellForRow(at: indexPath!) as UITableViewCell!
        
    }

}
