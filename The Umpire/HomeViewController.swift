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

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Refs().usrRef.child("\(Auth.auth().currentUser?.uid)").observeSingleEvent(of: .value) { (snapshot) in
            userAcc.user = Auth.auth().currentUser
            userAcc.email = Auth.auth().currentUser?.email
            userAcc.uid = Auth.auth().currentUser?.uid
            for child in snapshot.childSnapshot(forPath: "Leagues").children {
                let snap = child as? DataSnapshot
                userAcc.leagueNumbers.append((snap?.childSnapshot(forPath: "Leagues").value as! String?)!)
                userAcc.leagueNames.append((snap?.childSnapshot(forPath: "Leagues").childSnapshot(forPath: userAcc.leagueNumbers.last!).childSnapshot(forPath: "LeagueName").value as! String?)!)
                userAcc.teamNames.append((snap?.childSnapshot(forPath: "Leagues").childSnapshot(forPath: userAcc.leagueNumbers.last!).childSnapshot(forPath: "Team").value as! String?)!)
                userAcc.adminList.append((snap?.childSnapshot(forPath: "Leagues").value as! Bool?)!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
