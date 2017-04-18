//
//  AdminTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/17/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AdminTableViewController: UITableViewController {
    
    let user = FIRAuth.auth()?.currentUser
    let userUID = FIRAuth.auth()?.currentUser?.uid
    let ref = FIRDatabase.database().reference()
    
    var decider: Int!
    
    var tablePath: FIRDatabaseReference!
    var convertedArray = [String]()
    var league: String!
    var ageGroup: String!
    var selectedCell: String!
    var alertTextField: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("UserData").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.value as! String!
            self.dataObserver()
        })
        
        switch decider {
        case 0:
            tablePath = ref.child(league)
            print("Rename Age Group")
            
        case 1:
            print("Rename Team")
            
        case 2:
            print("Add/Remove Ages & Teams")
        
        case 3:
            print("Remove a Coach")
            
        default:
            print(LocalizedError.self)
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        tablePath.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.convertedArray.append(snap.value as! String)
                self.tableView.reloadData()
            }
            print(self.convertedArray)
            self.convertedArray.reverse()
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return convertedArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = convertedArray[indexPath.row]
        
        selectedCell = cell.textLabel?.text
        
        if decider == 0 {
            
            func displayMyAlertMessage(title:String, userMessage:String, editedField:UILabel)
            {
                
                let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
                
                myAlert.addTextField()
                
                let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
                    self.alertTextField = myAlert.textFields![0].text
                    self.ref.child("LeagueDatabase").child(self.league).updateChildValues([self.selectedCell:self.alertTextField])
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                
                myAlert.addAction(okAction)
                myAlert.addAction(cancelAction)
                
                self.present(myAlert, animated: true, completion: nil)
            }
        } else if decider == 1 {
            func displayMyAlertMessage(title:String, userMessage:String, editedField:UILabel)
            {
                
                let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
                
                myAlert.addTextField()
                
                let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
                    self.alertTextField = myAlert.textFields![0].text
                    self.ref.child("LeagueDatabase").child(self.league).observeSingleEvent(of: .value, with: { (snapshot) in
                        for age in snapshot.children {
                            self.ref.child("LeagueDatabase").child(self.league).child(age).updateChildValues([self.selectedCell:self.alertTextField])
                        }
                        self.ref.child("LeagueTeamLists").child(league).updateChildValues([self.selectedCell:self.alertTextField])
                    })
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                
                myAlert.addAction(okAction)
                myAlert.addAction(cancelAction)
                
                self.present(myAlert, animated: true, completion: nil)
            }
        } else if decider == 2 {
            
        } else if decider == 3 {
            
        } else {
            
        }

        return cell
    }

}
