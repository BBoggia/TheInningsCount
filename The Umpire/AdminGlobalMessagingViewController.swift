//
//  AminGlobalMessagingViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/23/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import CoreGraphics
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AdminGlobalMessagingViewController: UIViewController {

    let user = FIRAuth.auth()?.currentUser
    let userUID = FIRAuth.auth()?.currentUser?.uid
    let ref = FIRDatabase.database().reference()
    
    var league: String!
    var randNum: String!
    
    @IBOutlet weak var announcementTextField: UITextField!
    @IBAction func submit(_ sender: Any) {
        displayMyAlertMessage(title: "Your Message", userMessage: "\(self.announcementTextField.text!) \n\nReady to send it?")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("UserData").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.childSnapshot(forPath: "Name").value as! String!
            self.randNum = snapshot.childSnapshot(forPath: "RandomNumber").value as! String!
        })
            
        self.view.gradientOfView(withColors: UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.0), UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendMessage(withMessage message: String) {
        
        self.ref.child("LeagueData").child(self.randNum).child("Messages").childByAutoId().setValue(message)
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { action in
            self.sendMessage(withMessage: self.announcementTextField.text!)
        }
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
}
