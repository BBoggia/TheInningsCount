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
    var dates = [String]()
    
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
        self.ref.child("LeagueData").child(self.randNum).child("Messages").queryLimited(toLast: 15).observe(.value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as? FIRDataSnapshot
                self.messages.append(snap?.childSnapshot(forPath: "Message").value as! String!)
                self.dates.append(snap?.childSnapshot(forPath: "Date").value as! String!)
                self.clientTable.reloadData()
            }
            self.messages.reverse()
            self.dates.reverse()
        }, withCancel: nil)
    }
    
    deinit {
        if let refHandle = newMessageRefHandle  {
            self.ref.child("LeagueData").child(self.randNum).child("Messages").removeObserver(withHandle: refHandle)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = clientTable.dequeueReusableCell(withIdentifier: "cell") as! AdminMsgTableViewCell
        
        cell.msgLbl.text = messages[indexPath.row]
        cell.dateLbl.text = dates[indexPath.row]
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clientTable.estimatedRowHeight = 100
        clientTable.rowHeight = UITableViewAutomaticDimension
    }

}
