//
//  PlayerStatsViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/9/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PlayerStatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var playerDataTable: UITableView!
    
    let ref = FIRDatabase.database().reference()
    var dateList = [String]()
    var playerStatsList = [String]()
    var age: String!
    var playerData: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataObserver()
        
        self.playerDataTable.delegate = self
        self.playerDataTable.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        ref.child("Database").child(age).child(playerData).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.dateList.append(snap.key)
                self.playerStatsList.append(snap.value as! String)
                print(self.dateList)
                print(self.playerStatsList)
                self.playerDataTable.reloadData()
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return dateList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerDataTable.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = dateList[indexPath.row]
        cell?.detailTextLabel?.text = playerStatsList[indexPath.row]
        
        return cell!
    }
}
