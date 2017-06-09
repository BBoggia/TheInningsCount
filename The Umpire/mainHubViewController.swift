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
    
    let ref = Database.database().reference()
    var user = Auth.auth().currentUser
    var userUID: String!
    
    var teamName: String!
    var leagueName: String!

    @IBAction func roster(_ sender: Any) {
        displayMyAlertMessage(title: "Comming Soon", userMessage: "This feature is in development and will be released soon.")
    }
    @IBOutlet var inningsBtn: UIButton!
    @IBOutlet var dataBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coachesHub: UILabel!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBAction func logOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        performSegue(withIdentifier: "logout", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userUID = Auth.auth().currentUser?.uid as String!

        let teamNameRef = ref.child("UserData").child(userUID!)
        teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.teamName = snapshot.childSnapshot(forPath: "Team").value as! String!
            self.leagueName = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
            self.navBar.title = self.leagueName
            self.titleLabel.text = self.teamName
            
            if snapshot.childSnapshot(forPath: "status").value as! String! == "admin" {
                
                self.navBar.rightBarButtonItem = UIBarButtonItem(title: "Admin", style: .plain, target: self, action: #selector(self.adminSegue))

            }
        })
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            inningsBtn.heightAnchor.constraint(equalToConstant: 180).isActive = true
            titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 38)
            coachesHub.font = UIFont(name: coachesHub.font.fontName, size: 42)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adminSegue() {
        performSegue(withIdentifier: "toAdmin", sender: nil)
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }

}
