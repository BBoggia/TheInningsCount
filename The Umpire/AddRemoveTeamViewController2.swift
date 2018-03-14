//
//  AddRemoveTeamViewController2.swift
//  The Umpire
//
//  Created by Branson Boggia on 6/16/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AddRemoveTeamViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User!
    var userUID: String!
    var ref : DatabaseReference?
    
    @IBOutlet weak var tableView: UITableView!
    
    var tablePath: DatabaseReference!
    var convertedArray = [String]()
    var league: String!
    var ageGroup: String!
    var selectedCell: String!
    var alertTextField: String!
    var theSnapshot: DataSnapshot!
    var deleteIndexPath: NSIndexPath? = nil
    var randNum: String!
    var toDelete: String!
    var team: String!
    
    @IBAction func addBtn(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid
        
        ref?.child("UserData").child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
            self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
            self.dataObserver()
        })
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        
        self.tablePath = self.ref?.child("LeagueStats").child(self.randNum).child(self.league).child(self.ageGroup)
        
        self.tablePath.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.convertedArray.append(snap.key)
                self.tableView.reloadData()
            }
            print(self.convertedArray)
        })
    }
    
    func confirmDelete(title: String) {
        let alert = UIAlertController(title: "Delete Age", message: "Are you sure you want to permanently delete \(title)?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeletePlanet)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeletePlanet)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeletePlanet(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteIndexPath {
            tableView.beginUpdates()
            
            self.convertedArray.remove(at: indexPath.row)
            
            self.deleteFromDB()
            
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            deleteIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    func deleteFromDB() {
        
        self.ref?.child("UserData").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if snap.childSnapshot(forPath: "Team:").value as! String! == self.toDelete && snap.childSnapshot(forPath: "AgeGroup:").value as! String! == self.ageGroup {
                    let uid = snap.key
                    self.ref?.child("UserData").child(uid).child("Team:").setValue("removed")
                }
            }
        })
        
        self.ref?.child("LeagueData").child(randNum).child("Info").child(self.ageGroup).child(self.toDelete).removeValue()
        self.ref?.child("LeagueStats").child(league).child(ageGroup).child(toDelete).removeValue()
    }
    
    func cancelDeletePlanet(alertAction: UIAlertAction!) {
        deleteIndexPath = nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return convertedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = convertedArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteIndexPath = indexPath as NSIndexPath
            self.toDelete = convertedArray[indexPath.row]
            confirmDelete(title: self.toDelete)
        }
    }
    
}
