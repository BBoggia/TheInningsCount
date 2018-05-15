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

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func exitBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var sender: String!
    var leagueList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch sender {
        case "YourLeagues":
            tableView.delegate = self
            tableView.dataSource = self
            titleLbl.text = "Your Leagues"
            setupTable()
        case "Settings":
            titleLbl.text = "Settings"
        default:
            break
        }
    }
    
    func setupTable() {
        Refs().usrRef.child((Auth.auth().currentUser?.uid as String?)!).child("Leagues").observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.leagueList.append(snap.childSnapshot(forPath: "LeagueName").value as! String)
            }
        }
        tableView.isHidden = false
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagueList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = leagueList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as UITableViewCell?
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mainHub") as! mainHubViewController
        //Add data to send to next vc
        navigationController?.pushViewController(vc,animated: true)
    }
}
