//
//  TeamSelectViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/8/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class TeamSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var teamListTable: UITableView!
    
    let ref = FIRDatabase.database().reference()
    var teamList = [String]()
    var teamToPass: String!
    var age: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataObserver()
        
        self.teamListTable.delegate = self
        self.teamListTable.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        ref.child("Database").child(age).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.teamList.append(snap.key)
                print(self.teamList)
                print(snap.key)
                self.teamListTable.reloadData()
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
        return teamList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = teamListTable.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = teamList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = teamListTable.indexPathForSelectedRow
        let currentCell = teamListTable.cellForRow(at: indexPath!) as UITableViewCell!
        
        teamToPass = currentCell?.textLabel?.text
        
        performSegue(withIdentifier: "toPlayerStats", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayerStats" {
            
            let viewController = segue.destination as! PlayerStatsViewController
            
            viewController.age = age
            viewController.playerData = teamToPass
        }
    }
}
