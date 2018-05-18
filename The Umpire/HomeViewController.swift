//
//  HomeViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/18/18.
//  Copyright © 2018 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func lastLeague(_ sender: Any) {
        if let leagueName = defaults.string(forKey: "lastLeagueName") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mainHub") as! mainHubViewController
            vc.leagueName = leagueName
            vc.leagueNum = defaults.string(forKey: "lastLeagueNumber")!
            vc.Division = defaults.string(forKey: "lastLeagueDivision")!
            vc.team = defaults.string(forKey: "lastLeagueTeam")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            displayAlert(title: "Oops!", message: "It looks like you haven't joined a league yet.")
        }
    }
    @IBAction func yourLeagues(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dynamicPopup") as! ReusablePopupViewController
        vc.sender = "YourLeagues"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func joinLeague(_ sender: Any) {
        let alert = UIAlertController(title: "Join a League", message: "Enter the 5 digit pin number for the league you would like to request to join.", preferredStyle: .alert)
        alert.addTextField()
        
        let send = UIAlertAction(title: "Send", style: .default) { action in
            Refs().dataRef.child("Requests").child(alert.textFields![0].text!).child(userAcc.uid).setValue(["DateRequested":NSDate().userSafeDate, "DateAccepted" : "", "Name" : userAcc.firstName + userAcc.lastName, "Email" : userAcc.email, "Status" : false])
            Refs().usrRef.child(userAcc.uid).child("Requests").child(Refs().dataRef.child(alert.textFields![0].text!).value(forKey: "LeagueName") as! String).setValue(["DateRequested" : NSDate().userSafeDate, "DateAccepted" : "", "LeagueNumber" : alert.textFields![0].text!, "Status" : false])
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancel)
        alert.addAction(send)
    }
    @IBAction func createLeague(_ sender: Any) {
        
    }
    @IBAction func leagueAnnouncements(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dynamicPopup") as! ReusablePopupViewController
        vc.sender = "LeagueAnnouncements"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func settings(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dynamicPopup") as! ReusablePopupViewController
        vc.sender = "Settings"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    var leagueMsgs = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        retriveStats()
        populateTableView()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func retriveStats() {
        Refs().usrRef.child((Auth.auth().currentUser?.uid as String?)!).observeSingleEvent(of: .value) { (snapshot) in
            userAcc.user = Auth.auth().currentUser
            userAcc.email = Auth.auth().currentUser?.email
            userAcc.uid = Auth.auth().currentUser?.uid
            userAcc.firstName = snapshot.childSnapshot(forPath: "FirstName").value as! String?
            userAcc.lastName = snapshot.childSnapshot(forPath: "LastName").value as! String?
            if snapshot.childSnapshot(forPath: "Leagues").hasChildren() {
                for child in snapshot.childSnapshot(forPath: "Leagues").children {
                    let snap = child as? DataSnapshot
                    userAcc.leagueNumbers.append((snap?.value as! String?)!)
                    userAcc.leagueNames.append((snap?.childSnapshot(forPath: userAcc.leagueNumbers.last!).childSnapshot(forPath: "LeagueName").value as! String?)!)
                    userAcc.teamNames.append((snap?.childSnapshot(forPath: userAcc.leagueNumbers.last!).childSnapshot(forPath: "Team").value as! String?)!)
                    userAcc.adminList.append((snap?.childSnapshot(forPath: userAcc.leagueNumbers.last!).childSnapshot(forPath: "AdminStatus").value as! Bool?)!)
                }
            }
        }
    }
    
    func populateTableView() {
        if userAcc.leagueNumbers.count < 0 {
            for league in userAcc.leagueNumbers {
                Refs().dataRef.child(league).observeSingleEvent(of: .value) { (snapshot) in
                    var msgArray = [String]()
                    for msgs in snapshot.childSnapshot(forPath: "Messages").children {
                        let snap = msgs as? DataSnapshot
                        msgArray.append((snap?.key)!)
                    }
                    msgArray.reverse()
                    msgArray.removeSubrange(5...)
                    for index in 0...4 {
                        self.leagueMsgs.append(["name":snapshot.childSnapshot(forPath: "LeagueName").value as! String, "date": snapshot.childSnapshot(forPath: msgArray[index]).childSnapshot(forPath: "Date").value as! String, "message":snapshot.childSnapshot(forPath: msgArray[index]).childSnapshot(forPath: "Message").value as! String])
                    }
                }
            }
            leagueMsgs.sort { (($0 )["date"])! < (($1 )["date"])! }
        } else {
            leagueMsgs.append(["name":"It looks like there aren't any new messages.", "date":"", "message":""])
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        
        return cell!
    }
}
