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
    
    var ref : DatabaseReference?
    var user: User!
    var userUID = Auth.auth().currentUser?.uid as String!
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
    
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var whiteLbl: UILabel!
    @IBOutlet weak var playerNumberTextField: UITextField!
    @IBOutlet weak var pitchCountTextField: UITextField!
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var adminChoose: UIBarButtonItem!
    
    @IBAction func submit(_ sender: Any) {
        
        sendData()
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        user = Auth.auth().currentUser
        
        playerNumberTextField.delegate = self
        pitchCountTextField.delegate = self
        
        whiteLbl.layer.cornerRadius = 10
        
        if adminStop == nil {
        
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Choose Team", style: .plain, target: self, action: #selector(self.adminChooseTeam))
            
        } else if adminStop == true {
            let teamNameRef = self.ref?.child("UserData").child(self.userUID!)
            teamNameRef?.observeSingleEvent(of: .value, with: { (snapshot) in
                self.leagueName = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
                self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
                self.titleField.text = self.teamName
                self.navigationController?.title = self.leagueName
            })
        }
        
        userDate = NSDate().userSafeDate
        databaseDate = NSDate().datebaseSafeDate
        sortDate = ServerValue.timestamp()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        playerNumberTextField.inputAccessoryView = toolBar
        pitchCountTextField.inputAccessoryView = toolBar
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleField.font = UIFont(name: titleField.font.fontName, size: 55)
            lblText.font = UIFont(name: lblText.font.fontName, size: 28)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sendData() {
        
        ref?.child("LeagueStats").child(randNum).child(leagueName).child(age).child(teamName).childByAutoId().setValue(["Stat" as NSString!:"Player#: \(playerNumberTextField.text!) | Innings: \(pitchCountTextField.text!)" as NSString!, "Date" as NSString!:userDate as NSString!])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @objc func adminChooseTeam() {
        ref?.child("UserData").child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childSnapshot(forPath: "status").value as! String! == "admin" {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "adminAgeSelect") as! AdminDataEntryAgeTableViewController
                self.navigationController?.pushViewController(vc,animated: true)
                
            } else {
                let teamNameRef = self.ref?.child("UserData").child(self.userUID!)
                teamNameRef?.observeSingleEvent(of: .value, with: { (snapshot) in
                    self.teamName = snapshot.childSnapshot(forPath: "Team").value as! String!
                    self.leagueName = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
                    self.age = snapshot.childSnapshot(forPath: "AgeGroup").value as! String!
                    self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
                    self.titleField.text = self.teamName
                    self.navigationController?.title = self.leagueName
                    
                })
            }
        })
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
