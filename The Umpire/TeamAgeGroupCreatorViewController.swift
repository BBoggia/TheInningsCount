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
    var email: String!
    var password: String!
    var selectedAge: String!
    var ageGroups = [String]()
    var leagueList = [[String : [String]]]()
    let saveData = UserDefaults.standard
    var ref = Database.database().reference()
    var randomGenNum = ""
    
    @IBOutlet weak var ageTableView: UITableView!
    
    @IBAction func addAgeBtn(_ sender: Any) {
        displayTextEntryField(title: "Division Name", userMessage: "Enter the name of an age group then press confirm.")
    }
    
    @IBAction func createGroups(_ sender: Any) {
        
        let myAlert = UIAlertController(title: "Are you sure?", message: "Please verify that all of your divisions and their teams are correct before continuing.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { action in
            
            var dataToSave = self.saveData.array(forKey: "leagueData")
            dataToSave?.removeFirst()
            self.leagueList = dataToSave as! [[String : [String]]]
            
            self.randomString()
            self.createAccount()
            self.autoSignIn()
            
            self.performSegue(withIdentifier: "navController", sender: nil)
        }
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ageTableView.delegate = self
        self.ageTableView.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        displayMyAlertMessage(title: "Divisions", userMessage: "Here is where you can add divisions or age groups to your league; e.g. Age9, Age10, ect.\n\nTo create a division use the + icon in the top right hand corner, enter the name you want for it, then select it to start adding teams. If you only have one division in your league then just create one and add teams to it.")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        
        print(saveData.array(forKey: "leagueData") as? [[String:[String]]] as Any!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
     func createAccount() {
     
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
        if error == nil {
            self.autoSignIn()
            self.saveUID()
            
            let index = 0
            for dict in self.leagueList {
                
                let dictKey = Array(dict)[index].key
                let dictValue = Array(dict)[index].value
                
                for team in dictValue {
                    
                    self.ref.child("LeagueStats").child(self.randomGenNum).child(self.leagueName).child(dictKey).child(team).child("Long Date").setValue(["Date" as NSString! : "Date" as NSString!, "Stat" as NSString! : "Player Number | Innings Pitched" as NSString!])
                }
            }
     
            self.ref.child("LeagueData").child(self.randomGenNum).child("LeagueName").setValue(self.leagueName)
            self.ref.child("LeagueData").child(self.randomGenNum).child("Messages").childByAutoId().setValue(["Message":"Important announcements from the league Administrator will be displayed here.", "Date":"Date of Post"])
     
            let myAlert1 = UIAlertController(title: "IMPORTANT!", message: "This 5 digit code is needed by your coaches when they create an account to be able to use the app. Write it down, it has also been copied to your clipboard. \n|\n\(self.randomGenNum)", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
                UIPasteboard.general.string = self.randomGenNum
     
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
     
                self.performSegue(withIdentifier: "fromCL", sender: nil)
            }
                myAlert1.addAction(okAction)
                self.present(myAlert1, animated: true, completion: nil)
            } else {
                self.displayMyAlertMessage(title: "Oops!", userMessage: (error?.localizedDescription)!)
            }
        })
     }
     
     func saveUID() {
     
        let user = Auth.auth().currentUser
        let userUID = user?.uid
        
        ref.child("UserData").child("/\(userUID!)").child("AgeGroup").setValue("League Administrator")
        ref.child("UserData").child("/\(userUID!)").child("Team").setValue("League Administrator")
        ref.child("UserData").child("/\(userUID!)").child("League").child("Name").setValue(leagueName)
        ref.child("UserData").child("/\(userUID!)").child("League").child("RandomNumber").setValue(randomGenNum)
        ref.child("UserData").child("/\(userUID!)").child("status").setValue("admin")
     
        print(userUID!)
     }
     
     func autoSignIn() {
        Auth.auth().signIn(withEmail: self.email, password: self.password, completion: {
        (user, error) in
        if error == nil {
            }
        })
     }
     
     func randomString() {
     
        let letters : NSString = "0123456789"
        let len = UInt32(letters.length)
     
        var randomString = ""
     
        for _ in 0 ..< 5 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
     
        self.randomGenNum = randomString
        self.checkRandomString()
     }
     
     func checkRandomString() {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
        for child in snapshot.children {
            let snap = child as! DataSnapshot
            if self.randomGenNum == snap.key {
                self.randomString()
            } else {
     
            }
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
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func displayTextEntryField(title:String, userMessage:String)
    {
        
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        myAlert.addTextField()
        
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            
            if (myAlert.textFields![0].text!.contains("$")) ||
                (myAlert.textFields![0].text!.contains("/")) ||
                (myAlert.textFields![0].text!.contains("\\")) ||
                (myAlert.textFields![0].text!.contains("#")) ||
                (myAlert.textFields![0].text!.contains("[")) ||
                (myAlert.textFields![0].text!.contains("]")) ||
                (myAlert.textFields![0].text!.contains(".")) {
                self.displayMyAlertMessage(title: "Oops!", userMessage: "Division names cannot contain the following characters. \n '$' '.' '/' '\\' '#' '[' ']'")
            } else if self.ageGroups.contains(myAlert.textFields![0].text!) {
                    self.displayMyAlertMessage(title: "Oops!", userMessage: "One or more divisions cannot share the same name.")
            } else {
                self.ageGroups.append(myAlert.textFields![0].text!)
                print(self.ageGroups)
                self.ageTableView.reloadData()
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
        return ageGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ageTableView.dequeueReusableCell(withIdentifier: "createAgeCell")
        cell?.textLabel?.text = ageGroups[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = ageTableView.indexPathForSelectedRow
        let currentCell = ageTableView.cellForRow(at: indexPath!) as UITableViewCell!
        
        selectedAge = currentCell?.textLabel?.text
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "teamCreation") as! TeamCreationViewController
        vc.divSelection = selectedAge
        vc.leagueName = leagueName
        navigationController?.pushViewController(vc,animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let deletedAge = ageGroups[indexPath.row] as String!
         
            for var dict in leagueList {
                
                dict.removeValue(forKey: deletedAge!)
            }
            
            self.ageGroups.remove(at: indexPath.row)
            
            ageTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

struct divData {
    var leagueList = [[String : [String]]]()
}
