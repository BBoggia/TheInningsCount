//
//  SignupTeamSelectViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/29/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SignupTeamSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var teamTableView: UITableView!
    
    var teamList = [String]()
    var selectedTeam: String!
    var randomNum: String!
    var leagueName: String!
    
    let ref = FIRDatabase.database().reference()
    let ref2 = FIRDatabase.database().reference().child("UserData")
    let user = FIRAuth.auth()?.currentUser
    let userUID = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataObserver()
        
        teamTableView.delegate = self
        teamTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        ref.child("LeagueCodes").child(randomNum).observeSingleEvent(of: .value, with: { (snapshot) in
            self.leagueName = snapshot.value as! String!
            self.populateView()
        })
    }
    
    func populateView() {
        ref.child("LeagueTeamLists").child(self.leagueName).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.teamList.append(snap.key)
                print(self.teamList)
                print(snap.key)
                self.teamTableView.reloadData()
            }
        })
    }
    
    func saveUID() {
        
        let user = FIRAuth.auth()?.currentUser
        let userUID = user?.uid
        
        ref2.child("/\(userUID!)").child("Team").setValue(selectedTeam)
        ref2.child("/\(userUID!)").child("League").setValue(leagueName)
        ref2.child("/\(userUID!)").child("status").setValue("coach")
        
        print(userUID!)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = teamTableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = teamList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = teamTableView.indexPathForSelectedRow
        let currentCell = teamTableView.cellForRow(at: indexPath!) as UITableViewCell!
        
        selectedTeam = currentCell?.textLabel?.text
        
        saveUID()
        
        self.ref.child("LeagueTeamLists").child(self.leagueName).child(selectedTeam).child(userUID!).setValue(user?.email)
        
        performSegue(withIdentifier: "toTeamSelect", sender: nil)
    }
}
