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
    var userUID = FIRAuth.auth()?.currentUser?.uid as String!
    var ageList = [String]()
    var ageToPass: String!
    var league:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("User Data").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.value as! String!
            self.dataObserver()
        })
        
        self.ageListTable.delegate = self
        self.ageListTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dataObserver() {
        ref.child("LeagueDatabase").child(league).observeSingleEvent(of: .value, with: { (snapshot) in
            
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "teamSelect") as! TeamSelectViewController
        vc.age = ageToPass
        navigationController?.pushViewController(vc,animated: true)
    }

}
