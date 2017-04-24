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

class b810DataEntryViewController: UIViewController, UITextFieldDelegate {
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    var userUID = FIRAuth.auth()?.currentUser?.uid as String!
    let dateFormatter = DateFormatter()
    var currentDate = Date()
    
    var teamName: String!
    var leagueName: String!
    var userDate = ""
    var databaseDate = ""
    var sortDate: [AnyHashable:Any] = [:]
    var age: String!
    var randNum: String!
    var adminStop: Bool!
    
    @IBOutlet weak var playerNumberTextField: UITextField!
    @IBOutlet weak var pitchCountTextField: UITextField!
    @IBOutlet weak var titleField: UILabel!
    
    @IBAction func submit(_ sender: Any) {
        
        sendData()
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNumberTextField.delegate = self
        pitchCountTextField.delegate = self
        
        if adminStop == nil {
        
            ref.child("UserData").child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.childSnapshot(forPath: "status").value as! String! == "admin" {
                
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "adminAgeSelect") as! AdminDataEntryAgeTableViewController
                    self.navigationController?.pushViewController(vc,animated: true)
                
                } else {
                    let teamNameRef = self.ref.child("UserData").child(self.userUID!)
                    teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        self.teamName = snapshot.childSnapshot(forPath: "Team").value as! String!
                        self.leagueName = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
                        self.age = snapshot.childSnapshot(forPath: "AgeGroup").value as! String!
                        self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
                        self.titleField.text = self.teamName
                        self.navigationController?.title = self.leagueName

                    })
                }
            })
        } else if adminStop == true {
            let teamNameRef = self.ref.child("UserData").child(self.userUID!)
            teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
                self.leagueName = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
                self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
                self.titleField.text = self.teamName
                self.navigationController?.title = self.leagueName
            })
        }
        
        userDate = NSDate().userSafeDate
        databaseDate = NSDate().datebaseSafeDate
        sortDate = FIRServerValue.timestamp()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        playerNumberTextField.inputAccessoryView = toolBar
        pitchCountTextField.inputAccessoryView = toolBar
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleField.font = UIFont(name: titleField.font.fontName, size: 55)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sendData() {
        
        ref.child("LeagueStats").child(randNum).child(leagueName).child(age).child(teamName).childByAutoId().setValue("\(userDate) | Player#: \(playerNumberTextField.text!) | Innings: \(pitchCountTextField.text!)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func doneClicked() {
        view.endEditing(true)
    }

}

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}

extension NSDate {
    struct dates {
        static let userSafeDate = DateFormatter(dateFormat: "MM-dd-yy hh:mm a")
        static let databaseSafeDate = DateFormatter(dateFormat: "MM-dd-yy hh:mm:SSS a")
    }
    var userSafeDate: String {
        return dates.userSafeDate.string(from: self as Date)
    }
    var datebaseSafeDate: String {
        return dates.databaseSafeDate.string(from: self as Date)
    }
}
