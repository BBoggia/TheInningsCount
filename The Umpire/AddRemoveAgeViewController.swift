//
//  AddRemoveAgeViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 5/17/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AddRemoveAgeTableViewController: UITableViewController {
    
    var user: User!
    var userUID: String!
    
    var tablePath: DatabaseReference!
    var convertedArray = [String]()
    var league: String!
    var alertTextField: String!
    var theSnapshot: DataSnapshot!
    var randNum: String!
    
    @IBAction func addBtn(_ sender: Any) {
        let myAlert = UIAlertController(title: "Add Division", message: "Enter the name of the division you want to add.", preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addTextField()
        
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            if myAlert.textFields![0].text?.rangeOfCharacter(from: charSet) != nil {
                
                self.displayAlert(title: "Oops!", message: "Your team name cannot contain the following characters.\n'$'  '.'  '/'  '\\'  '#'  '['  ']'")
            } else if (myAlert.textFields![0].text!.isEmpty) {
                
                self.displayAlert(title: "Oops!", message: "You cannot leave a teams name blank.")
            } else if self.convertedArray.contains(myAlert.textFields![0].text!) {
                
                self.displayAlert(title: "Oops!", message: "One or more teams cannot share the same name.")
            } else {
                
                self.alertTextField = myAlert.textFields![0].text
                self.convertedArray.append(self.alertTextField)
                self.tablePath.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    self.tablePath.child(self.alertTextField).setValue("placeholder")
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                    self.tableView.reloadData()
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid
        
        Refs().usrRef.child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.childSnapshot(forPath: "Name").value as! String?
            self.randNum = snapshot.childSnapshot(forPath: "RandomNumber").value as! String?
            self.dataObserver()
        })
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AddRemoveAgeTableViewController.longPress(_:)))
        longPressGesture.minimumPressDuration = 1.25
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.tableView.addGestureRecognizer(longPressGesture)
        displayAlert(title: "League Management", message: "Here you can add divisions by pressing the plus button, remove them by sliding left, and rename them by pressing and holding. To view a divisions teams just select one from the list.\n")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        
        self.tablePath = Refs().statRef.child(self.randNum).child(self.league)
        
        tablePath.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.convertedArray.append(snap.key)
                self.tableView.reloadData()
            }
            print(self.convertedArray)
        })
    }
    
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let myAlert = UIAlertController(title: "Rename Division", message: "Enter the name you want to change \(self.convertedArray[indexPath.row]) to.", preferredStyle: UIAlertControllerStyle.alert)
                myAlert.addTextField()
                
                let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
                        if myAlert.textFields![0].text?.rangeOfCharacter(from: charSet) != nil {
                            
                            self.displayAlert(title: "Oops!", message: "Your team name cannot contain the following characters.\n'$'  '.'  '/'  '\\'  '#'  '['  ']'")
                        } else if (myAlert.textFields![0].text!.isEmpty) {
                            
                            self.displayAlert(title: "Oops!", message: "You cannot leave a teams name blank.")
                        } else if self.convertedArray.contains(myAlert.textFields![0].text!) {
                            
                            self.displayAlert(title: "Oops!", message: "One or more teams cannot share the same name.")
                        } else {
                            self.alertTextField = myAlert.textFields![0].text
                            
                            Refs().statRef.child(self.randNum).child(self.league).observeSingleEvent(of: .value, with: { (snapshot) in
                                Refs().statRef.child(self.randNum).child(self.league).child(self.alertTextField).setValue(snapshot.childSnapshot(forPath: self.convertedArray[indexPath.row]).value)
                                Refs().statRef.child(self.randNum).child(self.league).child(self.convertedArray[indexPath.row]).removeValue()
                            })
                        }
                    /*self.ref?.child("UserData").observeSingleEvent(of: .value, with: { (snapshot) in
                        for child in snapshot.children {
                            let snap = child as! DataSnapshot
                            
                            if snap.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String! == self.league && snap.childSnapshot(forPath: "AgeGroup").value as! String! == self.convertedArray[indexPath.row] {
                                self.ref?.child("UserData").child(snap.key).child("AgeGroup").setValue(self.alertTextField)
                            }
                        }
                    })*/
                    self.tableView.reloadData()
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                myAlert.addAction(okAction)
                myAlert.addAction(cancelAction)
                self.present(myAlert, animated: true, completion: nil)
                
            }
        }
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
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as UITableViewCell?
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "arvc") as! AddRemoveTeamTableViewController
        vc.ageGroup = convertedArray[(indexPath?.row)!]
        vc.randNum = randNum
        vc.league = league
        vc.tablePath = tablePath.child((currentCell?.textLabel?.text)!)
        navigationController?.pushViewController(vc,animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Refs().statRef.child(self.randNum).child(self.league).child(self.convertedArray[indexPath.row]).removeValue()
            self.convertedArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
