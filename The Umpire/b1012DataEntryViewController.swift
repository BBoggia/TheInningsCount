//
//  b1012DataEntryViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 1/12/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class b1012DataEntryViewController: UIViewController, UITextFieldDelegate {
    
    let ref = FIRDatabase.database().reference().child("Database/baseball1012/")
    let mainRef = FIRDatabase.database()
    var currentData = 0
    let user = FIRAuth.auth()?.currentUser
    var userUID = FIRAuth.auth()?.currentUser?.uid
    let dateFormatter = DateFormatter()
    var currentDate = Date()
    
    var teamName = "team"
    var userDate = ""
    var databaseDate = ""
    
    @IBOutlet weak var playerNumberTextField: UITextField!
    @IBOutlet weak var pitchCountTextField: UITextField!
    
    @IBAction func submit(_ sender: Any) {
        
        sendData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNumberTextField.delegate = self
        pitchCountTextField.delegate = self
        
        let teamNameRef = mainRef.reference().child("User-Team/\(userUID!)")
        teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.teamName = snapshot.value as! String!
        })
        
        userDate = NSDate().userSafeDate
        databaseDate = NSDate().datebaseSafeDate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendData() {
        
        FIRDatabase.database().reference().child("Database").child("baseball1012").child(teamName).child("\(self.databaseDate)").setValue("\(userDate) | Player#: \(playerNumberTextField.text!) | Innings Pitched: \(pitchCountTextField.text!)")
    }
    
}
