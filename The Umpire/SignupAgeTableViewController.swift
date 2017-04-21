//
//  SignupAgeTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/21/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignupAgeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var teamTableView: UITableView!
    
    var ageList = [String]()
    var selectedAge: String!
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
        ref.child("LeagueData").child("LeagueName").observeSingleEvent(of: .value, with: { (snapshot) in
            self.leagueName = snapshot.value as! String!
            self.populateView()
        })
    }
    
    func populateView() {
        ref.child("LeagueData").child(self.randomNum).child("Info").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.ageList.append(snap.key)
                print(self.ageList)
                print(snap.key)
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
            
            self.performSegue(withIdentifier: "toTeamSelect", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    func saveUID() {
        
        let user = FIRAuth.auth()?.currentUser
        let userUID = user?.uid
        
        ref2.child("/\(userUID!)").child("AgeGroup").setValue(selectedAge)
        ref2.child("/\(userUID!)").child("League").child("Name").setValue(leagueName)
        ref2.child("/\(userUID!)").child("League").child("RandNum").setValue(randomNum)
        
        print(userUID!)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ageList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = teamTableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = ageList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = teamTableView.indexPathForSelectedRow
        let currentCell = teamTableView.cellForRow(at: indexPath!) as UITableViewCell!
        
        selectedAge = currentCell?.textLabel?.text
        
        displayMyAlertMessage(title: "Confirm", userMessage: "You selected \(selectedAge), is this correct?")
    }
}
