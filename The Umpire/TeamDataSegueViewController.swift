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
    
    var ref : DatabaseReference? = nil
    var userUID: String!
    var ageList = [String]()
    var ageToPass: String!
    var league:String!
    var randNum: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        userUID = Auth.auth().currentUser?.uid
        
        ref?.child("UserData").child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
            self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
            self.dataObserver()
        })
        
        self.ageListTable.delegate = self
        self.ageListTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func dataObserver() {
        ref?.child("LeagueStats").child(self.randNum).child(self.league).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.ageList.append(snap.key)
                print(self.ageList)
                self.ageListTable.reloadData()
            }
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
