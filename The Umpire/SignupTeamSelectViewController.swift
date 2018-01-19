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
    var age: String!
    var randomNum: String!
    var leagueName: String!
    
    var ref : DatabaseReference?
    var ref2 : DatabaseReference?
    let user = Auth.auth().currentUser
    var userUID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        ref2 = Database.database().reference().child("UserData")
        
        userUID = Auth.auth().currentUser?.uid
        
        ref2?.child("\(userUID!)").observeSingleEvent(of: .value, with: { (snapshot) in
            self.randomNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
            
            self.leagueName = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
            
            self.age = snapshot.childSnapshot(forPath: "AgeGroup").value as! String!
            
            self.populateView()
        })
        
        teamTableView.delegate = self
        teamTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateView() {
        ref?.child("LeagueStats").child(self.randomNum).child(self.leagueName).child(age).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.teamList.append(snap.key)
                print(self.teamList)
                self.teamTableView.reloadData()
            }
        })
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            action in
            
            self.saveUID()
            
            self.ref?.child("LeagueData").child(self.randomNum).child("Info").child(self.age).child(self.selectedTeam).child("Coaches").child(self.userUID!).setValue(self.user?.email)
            self.ref2?.child(self.userUID!).child("status").setValue("coach")
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            self.performSegue(withIdentifier: "toMain", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    func saveUID() {
        
        let user = Auth.auth().currentUser
        let userUID = user?.uid
        
        ref2?.child("/\(userUID!)").child("Team").setValue(selectedTeam)
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
        
        displayMyAlertMessage(title: "Confirm", userMessage: "You selected \(selectedTeam!), is this correct?")
    }
}
