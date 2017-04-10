//
//  AddRosterViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/7/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AddRosterViewController: UIViewController {
    
    var ref = FIRDatabase.database().reference()
    var userUid = FIRAuth.auth()?.currentUser?.uid as String!
    
    var teamName: String!
    var leagueName: String!
    var rosterList = [String]()
    var stepperValue1: Int!
    var stepperValue5: Int!
    var stepperValue10: Int!
    var combinedNum = 0

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var playerDisplay: UILabel!
    @IBOutlet weak var addNumberLabel: UILabel!
    @IBAction func add(_ sender: Any) {
    }
    @IBAction func remove(_ sender: Any) {
    }
    @IBAction func clear(_ sender: Any) {
    }
    @IBAction func submit(_ sender: Any) {
    }
    @IBAction func stepper1(_ sender: Any) {
        stepperValue1 = (Int((sender as AnyObject).value))
        combinedNum = stepperValue1 + combinedNum
    }
    @IBAction func stepper2(_ sender: Any) {
        stepperValue5 = (Int((sender as AnyObject).value))
        combinedNum = stepperValue5 + combinedNum
    }
    @IBAction func stepper3(_ sender: Any) {
        stepperValue10 = (Int((sender as AnyObject).value))
        combinedNum = stepperValue10 + combinedNum
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let teamNameRef = ref.child("User Data").child(userUid!)
        teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.teamName = snapshot.childSnapshot(forPath: "Team").value as! String!
            self.leagueName = snapshot.childSnapshot(forPath: "League").value as! String!
            self.navBar.title = self.leagueName
        })
        
        combinedNum = stepperValue1 as Int! + stepperValue5 as Int! + stepperValue10 as Int!
        
        addNumberLabel.text = "\(combinedNum)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
