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

class b810DataEntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    var isAdmin: Bool!
    let playerNumberArr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99]
    let inningPitchArr = [0, 1, 2, 3, 4, 5, 6]
    var playerNumberPicked: Int!
    var inningNumberPicked: Int!
    
    @IBOutlet weak var whiteLbl: UILabel!
    @IBOutlet weak var numberPicker: UIPickerView!
    @IBOutlet weak var pitchPicker: UIPickerView!
    @IBOutlet weak var adminChoose: UIBarButtonItem!
    
    @IBAction func submit(_ sender: Any) {
        
        sendData()
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        user = Auth.auth().currentUser
        
        whiteLbl.layer.cornerRadius = 10
        
        if isAdmin == nil {
        
            adminChooseTeam()
            
        } else if isAdmin == true {
            let teamNameRef = self.ref?.child("UserData").child(self.userUID!)
            teamNameRef?.observeSingleEvent(of: .value, with: { (snapshot) in
                self.leagueName = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "Name").value as! String!
                self.randNum = snapshot.childSnapshot(forPath: "League").childSnapshot(forPath: "RandomNumber").value as! String!
                self.navigationController?.title = self.teamName
            })
        }
        
        userDate = NSDate().userSafeDate
        databaseDate = NSDate().datebaseSafeDate
        sortDate = ServerValue.timestamp()
        
        /*
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
        */
        
        numberPicker.delegate = self
        numberPicker.dataSource = self
        pitchPicker.delegate = self
        pitchPicker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sendData() {
        
        ref?.child("LeagueStats").child(randNum).child(leagueName).child(age).child(teamName).childByAutoId().setValue(["Stat" as NSString!:"Player#: \(playerNumberPicked!) | Innings: \(inningNumberPicked!)" as NSString!, "Date" as NSString!:userDate as NSString!])
    }
    /*
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
 */
    
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
                    self.navigationController?.title = self.teamName
                    
                })
            }
        })
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return playerNumberArr.count
        } else {
            return inningPitchArr.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return "\(playerNumberArr[row])"
        } else {
            return "\(inningPitchArr[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            playerNumberPicked = self.playerNumberArr[row]
        } else {
            inningNumberPicked = self.inningPitchArr[row]
        }
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
