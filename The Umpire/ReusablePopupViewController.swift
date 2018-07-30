//
//  ReusablePopupViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 5/14/18.
//  Copyright © 2018 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ReusablePopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var settingsBackgroundLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var settingsStackView: UIStackView!
    @IBAction func changePassword(_ sender: UIButton) {
        let alert = UIAlertController(title: "Password Reset", message: "Enter your new password.", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.textFields![0].placeholder = "New Password"
        alert.textFields![1].placeholder = "Retype New Password"
        let confirm = UIAlertAction(title: "Confirm", style: .default) { action in
            if alert.textFields![0].text != alert.textFields![1].text {
                self.displayAlert(title: "Oops!", message: "Your passwords don't match!")
            } else {
                Auth.auth().currentUser?.updatePassword(to: alert.textFields![0].text!, completion: { (err) in
                    if err == nil {
                        self.displayAlert(title: "Success!", message: "Your password has been changed.")
                    } else {
                        self.displayAlert(title: "Oops!", message: (err?.localizedDescription)!)
                    }
                })
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func changeEmail(_ sender: UIButton) {
        let alert = UIAlertController(title: "Update Email", message: "Enter your new email address.", preferredStyle: .alert)
        alert.addTextField()
        let confirm = UIAlertAction(title: "Confirm", style: .default) { action in
            Auth.auth().currentUser?.updateEmail(to: alert.textFields![0].text!, completion: { (err) in
                if err == nil {
                    userAcc.email = alert.textFields![0].text
                    Refs().usrRef.child(userAcc.uid).child("Email").setValue(alert.textFields![0].text!)
                    Refs().usrRef.child(userAcc.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        for child in snapshot.childSnapshot(forPath: "Leagues").children {
                            let snap = child as! DataSnapshot
                            Refs().dataRef.child(snap.key).child("CoachInfo").child(userAcc.uid).child("Email").setValue(alert.textFields![0].text!)
                        }
                        if snapshot.hasChild("Requests") {
                            for child in snapshot.childSnapshot(forPath: "Requests").children {
                                let snap = child as! DataSnapshot
                                Refs().dataRef.child(snap.key).child("Requests").child(userAcc.uid).child("Email").setValue(alert.textFields![0].text!)
                            }
                        }
                        
                    })
                    self.displayAlert(title: "Success", message: "Your email has been changed!")
                } else {
                    self.displayAlert(title: "Oops!", message: (err?.localizedDescription)!)
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func exitBtn(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    var sender: String!
    var leagueList = [[String:String]]()
    var settingsList = ["Change Email", "Change Password", "Report a Bug", "Contact Us"]
    var shouldDissapear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leagueList.removeAll()
        switch sender {
        case "YourLeagues":
            tableView.delegate = self
            tableView.dataSource = self
            titleLbl.text = "Your Leagues"
            setupTable()
        case "Settings":
            settingsTableView.delegate = self
            settingsTableView.dataSource = self
            titleLbl.text = "Settings"
            settingsStackView.isHidden = false
        case "LeagueAnnouncements":
            tableView.delegate = self
            tableView.dataSource = self
            titleLbl.text = "League Alerts"
            setupTable()
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldDissapear == true {
            self.view.removeFromSuperview()
        }
    }
    
    func setupTable() {
        for i in userAcc.leagues {
            if i.leagueName == nil {
                userAcc.leagues.dropFirst()
                continue
            }
            self.leagueList.append(["LeagueName" : i.leagueName, "LeagueNumber" : i.leagueNumber, "Team" : i.team, "Division" : i.division])
        }
        switch sender {
        case "Settings":
            if settingsList.count == 0 {
                settingsList.append("Oops! It looks like you haven't joined any leagues yet.")
                popupView.layer.bounds.size.height = titleLbl.bounds.height + 66
            } else if settingsList.count <= 6 {
                popupView.layer.bounds.size.height = CGFloat(Int(titleLbl.bounds.height) + (settingsList.count * 50) + 16)
            }
            settingsTableView.isHidden = false
            settingsBackgroundLbl.isHidden = false
            settingsTableView.reloadData()
        case "LeagueAnnouncements":
            fallthrough
        case "YourLeagues":
            tableView.isHidden = false
            tableView.reloadData()
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sender {
        case "Settings":
            return settingsList.count
        default:
            return leagueList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sender {
        case "Settings":
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1")
            cell?.textLabel?.text = settingsList[indexPath.row]
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = leagueList[indexPath.row]["LeagueName"]
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sender {
        case "YourLeagues":
            let indexPath = tableView.indexPathForSelectedRow
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mainHub") as! mainHubViewController
            vc.leagueName = leagueList[(indexPath?.row)!]["LeagueName"]
            vc.leagueNum = leagueList[(indexPath?.row)!]["LeagueNumber"]!
            vc.team = leagueList[(indexPath?.row)!]["Team"]
            vc.Division = leagueList[(indexPath?.row)!]["Division"]
            self.shouldDissapear = true
            navigationController?.pushViewController(vc,animated: true)
        case "LeagueAnnouncements":
            let indexPath = tableView.indexPathForSelectedRow
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "leagueAnnouncements") as! ViewLeagueAnnouncementsViewController
            vc.league = leagueList[(indexPath?.row)!]["LeagueName"]
            vc.randNum = leagueList[(indexPath?.row)!]["LeagueNumber"]!
            self.shouldDissapear = true
            navigationController?.pushViewController(vc,animated: true)
        case "Settings":
            //let indexPath = settingsTableView.indexPathForSelectedRow
            break
        default:
            break
        }
    }
}
