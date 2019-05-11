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
    @IBOutlet weak var titleLbl: UILabel!
    
    var user: User!
    var userUID: String!
    var msgRef: DatabaseReference!
    private var newMessageRefHandle: DatabaseHandle?
    
    var league: String!
    var randNum: String!
    var messages = [String]()
    var dates = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid

        clientTable.delegate = self
        clientTable.dataSource = self
        
        self.msgRef = Refs().dataRef.child(self.randNum).child("Messages")
        self.dataObserver()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleLbl.font = .boldSystemFont(ofSize: 64)        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        Refs().dataRef.child(self.randNum).child("Messages").queryLimited(toLast: 15).observe(.value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as? DataSnapshot
                self.messages.append((snap?.childSnapshot(forPath: "Message").value as! String?)!)
                self.dates.append((snap?.childSnapshot(forPath: "Date").value as! String?)!)
                self.clientTable.reloadData()
            }
            self.messages.reverse()
            self.dates.reverse()
        }, withCancel: nil)
    }
    
    deinit {
        if let refHandle = newMessageRefHandle  {
            Refs().dataRef.child(self.randNum).child("Messages").removeObserver(withHandle: refHandle)
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
