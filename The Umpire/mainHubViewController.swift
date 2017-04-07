//
//  mainHubViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/6/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class mainHubViewController: UIViewController {
    
    let ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser
    var userUID = FIRAuth.auth()?.currentUser?.uid as String!
    
    var teamName: String!
    var leagueName: String!

    @IBAction func roster(_ sender: Any) {
        displayMyAlertMessage(title: "Comming Soon", userMessage: "This feature is in development and will be released soon.")
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBAction func logOut(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        performSegue(withIdentifier: "logout", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let teamNameRef = ref.child("User Data").child(userUID!)
        teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.teamName = snapshot.childSnapshot(forPath: "Team").value as! String!
            self.leagueName = snapshot.childSnapshot(forPath: "League").value as! String!
            self.navBar.title = self.leagueName
            self.titleLabel.text = self.teamName
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }

}
