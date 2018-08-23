//
//  TeamAgeGroupCreatorViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/27/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TeamAgeGroupCreatorViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var leagueName: String!
    var selectedAge: String!
    var divisions = [String]()
    var leagueData = [String:[String]]()
    var savePath = [String:[String]]()
    var randomGenNum = ""
    
    @IBOutlet weak var ageTableView: UITableView!
    
    @IBAction func addAgeBtn(_ sender: Any) {
        displayTextEntryField(title: "Division Name", userMessage: "Enter the name of your age group or division then press confirm.")
    }
    
    @IBAction func createGroups(_ sender: Any) {
        
        let myAlert = UIAlertController(title: "Are you sure?", message: "Please verify that all of your divisions and their teams are correct before continuing.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { action in
            self.savePath.removeValue(forKey: "placeHolder")
            self.randomString()
        }
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(["placeHolder":[""]], forKey: "leagueData")
        savePath = UserDefaults.standard.dictionary(forKey: "leagueData") as! [String:[String]]
        self.ageTableView.delegate = self
        self.ageTableView.dataSource = self
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: false)
        displayAlert(title: "Divisions", message: "Here is where you can add divisions or age groups to your league; e.g. Age9 Boys, Age10 Girls, ect.")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        print(savePath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createdLeague" {
            
        }
    }
    
     func createLeague() {
        var league = UserDefaults.standard.dictionary(forKey: "leagueData") as! [String:[String]]
        if league["placeHolder"] != nil {
            league.removeValue(forKey: "placeHolder")
        }
        for i in league.keys.reversed() {
            let leagueTeams = league[i]
            for j in leagueTeams! {
                Refs().statRef.child(self.randomGenNum).child(self.leagueName).child(i).child(j).child("Long Date").setValue(["Date":"Date", "Player":"Player Number", "Innings":"Innings Pitched", "Coach":"Coach", "ID":"ID"])
            }
        }
        Refs().dataRef.child(self.randomGenNum).child("LeagueName").setValue(self.leagueName)
        Refs().dataRef.child(self.randomGenNum).child("Messages").childByAutoId().setValue(["Message":"Important announcements from the league Admin will be displayed here.", "Date":" "])
        Refs().dataRef.child(self.randomGenNum).child("CoachInfo").child(userAcc.uid).setValue(["Name" : userAcc.firstName + " " + userAcc.lastName, "Email" : userAcc.email, "AdminStatus" : true, "OwnerStatus":true, "Division":"n/a", "Team":"n/a", "DateAccepted":NSDate().userSafeDate, "DateRequested":"n/a"])
        Refs().usrRef.child(userAcc.uid).child("Leagues").child(randomGenNum).setValue(["LeagueName":leagueName, "Division":"n/a", "Team":"n/a", "AdminStatus":true, "OwnerStatus":true])
 
        let myAlert1 = UIAlertController(title: "IMPORTANT!", message: "This 5 digit code is needed by your coaches when they create an account to be able to use the app. Write it down, it has also been copied to your clipboard. \n|\n\(self.randomGenNum)", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            UIPasteboard.general.string = self.randomGenNum
            self.navigationController?.popToRootViewController(animated: true)
        }
        myAlert1.addAction(okAction)
        self.present(myAlert1, animated: true, completion: nil)
     }
     
     func randomString() {
        let letters : NSString = "0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ... 4 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        self.checkRandomString(x: randomString)
     }
     
    func checkRandomString(x: String) {
        Refs().ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("LeagueStats") {
                print("HasLeagueStats")
                if snapshot.childSnapshot(forPath: "LeagueStats").hasChild(self.randomGenNum) {
                    self.randomString()
                } else {
                    self.randomGenNum = x
                    self.createLeague()
                }
            } else {
                print("NoLeagueStats")
                self.randomGenNum = x
                self.createLeague()
            }
        })
     }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    @objc func doneClicked() {
        self.view.endEditing(true)
    }
    
    func displayTextEntryField(title:String, userMessage:String) {
        
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addTextField()
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            
            if (myAlert.textFields![0].text!.rangeOfCharacter(from: charSet) != nil) {
                
                self.displayAlert(title: "Oops!", message: "Division names cannot contain the following characters. \n '$' '.' '/' '\\' '#' '[' ']'")
            } else if self.divisions.contains(myAlert.textFields![0].text!) {
                
                self.displayAlert(title: "Oops!", message: "You cannout have more than one division with the same name.")
            } else if myAlert.textFields![0].text!.isEmpty {
                
                self.displayAlert(title: "Oops!", message: "You can't leave the name blank.")
            } else {
                self.divisions.append((myAlert.textFields![0].text!))
                self.ageTableView.reloadData()
                print(self.divisions)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return divisions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ageTableView.dequeueReusableCell(withIdentifier: "createAgeCell")
        cell?.textLabel?.text = divisions[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = ageTableView.indexPathForSelectedRow
        let currentCell = ageTableView.cellForRow(at: indexPath!) as UITableViewCell?
        
        selectedAge = currentCell?.textLabel?.text
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "teamCreation") as! TeamCreationViewController
        vc.divSelection = selectedAge
        vc.leagueName = leagueName
        tableView.deselectRow(at: indexPath!, animated: true)
        navigationController?.pushViewController(vc,animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            divisions.remove(at: indexPath.row)
            ageTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
