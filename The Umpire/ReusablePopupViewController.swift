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
    @IBAction func exitBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var sender: String!
    var leagueList = [[String:String]]()
    var settingsList = ["Change Email", "Change Password", "Report a Bug", "Contact Us"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        case "LeagueAnnouncements":
            tableView.delegate = self
            tableView.dataSource = self
            titleLbl.text = "League Announcements"
            setupTable()
        default:
            break
        }
        //Auth.auth().currentUser?.
    }
    
    func setupTable() {
        Refs().usrRef.child((Auth.auth().currentUser?.uid as String?)!).child("Leagues").observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.leagueList.append(["LeagueName" : snap.childSnapshot(forPath: "LeagueName").value as! String, "LeagueNumber" : snap.key, "Team" : snap.childSnapshot(forPath: "Team").value as! String, "Division" : snap.childSnapshot(forPath: "Division").value as! String])
            }
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
        default:
            tableView.isHidden = false
            tableView.reloadData()
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
            navigationController?.pushViewController(vc,animated: true)
        case "LeagueAnnouncements":
            let indexPath = tableView.indexPathForSelectedRow
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "") as! ViewLeagueAnnouncementsViewController
            vc.league = leagueList[(indexPath?.row)!]["LeagueName"]
            vc.randNum = leagueList[(indexPath?.row)!]["LeagueNumber"]!
            navigationController?.pushViewController(vc,animated: true)
        case "Settings":
            let indexPath = settingsTableView.indexPathForSelectedRow
            
        default:
            break
        }
    }
}
