//
//  s1012DataEntryViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 1/12/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class s1012DataEntryViewController: UIViewController {
    
    let ref = FIRDatabase.database().reference().child("Database/softball1012/")
    let mainRef = FIRDatabase.database()
    var currentData = 0
    let user = FIRAuth.auth()?.currentUser
    var userUID = FIRAuth.auth()?.currentUser?.uid
    var teamName = "team"
    
    
    @IBOutlet weak var playerNumberTextField: UITextField!
    @IBOutlet weak var pitchCountTextField: UITextField!
    
    @IBAction func submit(_ sender: Any) {
        
        configureData()
        sendData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let teamNameRef = mainRef.reference().child("User-Team/\(userUID!)")
        teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.teamName = snapshot.value as! String!
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureData() {
        
        let playerRef = ref.child(teamName).child(playerNumberTextField.text!)
        
        playerRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.currentData = (snapshot.value as? Int)!
            
            let newData = self.currentData + (Int(self.pitchCountTextField.text!))!
            
            self.currentData = newData
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func sendData() {
        mainRef.reference().child("User-Team/").child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.teamName = snapshot.value as! String!
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //let team = mainRef.reference().child("User-Team")
        
        let teamName = self.teamName
        
        let playerRef = ref.child("\(teamName)/\(playerNumberTextField.text!)")
        
        playerRef.setValue(Int(pitchCountTextField.text!)! + currentData)
    }
    
}
