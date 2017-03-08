//
//  TeamDataSegueViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 2/27/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class TeamDataSegueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ageListTable: UITableView!
    
    let ref = FIRDatabase.database().reference()
    var ageList = [String]()
    var ageToPass: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataObserver()
        
        self.ageListTable.delegate = self
        self.ageListTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dataObserver() {
        ref.child("Database").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.ageList.append(snap.key)
                print(self.ageList)
                print(snap.key)
                self.ageListTable.reloadData()
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
        return ageList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ageListTable.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = ageList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = ageListTable.indexPathForSelectedRow
        let currentCell = ageListTable.cellForRow(at: indexPath!) as UITableViewCell!
        
        ageToPass = currentCell?.textLabel?.text
        
        performSegue(withIdentifier: "toTeamSelect", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTeamSelect" {
            
            var viewController = segue.destination as! TeamSelectViewController
            
            TeamSelectViewController.team = ageToPass
        }
    }

}
