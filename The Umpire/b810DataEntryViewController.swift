//
//  b810DataEntryViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 1/12/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class b810DataEntryViewController: UIViewController {
    
    let ref = FIRDatabase.database().reference().child("Database/baseball810/")
    let mainRef = FIRDatabase.database()
    var currentData = 0
    let user = FIRAuth.auth()?.currentUser
    var userUID = FIRAuth.auth()?.currentUser?.uid
    var teamName = "team"
    var timeStamp = ""
    
    @IBOutlet weak var playerNumberTextField: UITextField!
    @IBOutlet weak var pitchCountTextField: UITextField!
    
    @IBAction func submit(_ sender: Any) {
        
        sendData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let teamNameRef = mainRef.reference().child("User-Team/\(userUID!)")
        teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.teamName = snapshot.value as! String!
        })
        
        timeStamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .short, timeStyle: .short)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendData() {
        mainRef.reference().child("User-Team/").child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.teamName = snapshot.value as! String!
            
        }) { (error) in
            print(error.localizedDescription)
        }

        let dataRef = ref.child(teamName)
        
        dataRef.child("\(timeStamp)").setValue("Player Number: \(playerNumberTextField.text!) Innings Pitched: \(pitchCountTextField.text!)")
    }

}
