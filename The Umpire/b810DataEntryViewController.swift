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
    
    var user: User!
    var userUID = Auth.auth().currentUser?.uid as String?
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
    var playerNumberPicked: Int! = 1
    var inningNumberPicked: Int! = 0
    var fromAdminList = false
    var ID: String!
    
    @IBOutlet weak var whiteLbl: UILabel!
    @IBOutlet weak var numberPicker: UIPickerView!
    @IBOutlet weak var pitchPicker: UIPickerView!
    @IBOutlet weak var adminChoose: UIBarButtonItem!
    
    @IBAction func submit(_ sender: Any) {
        
        if playerNumberPicked == nil || inningNumberPicked == nil {
            displayAlert(title: "Oops!", message: "An error has occured please try again.")
        } else {
            sendData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser
        whiteLbl.layer.cornerRadius = 10
        if isAdmin == true && fromAdminList == false {
            adminChooseTeam()
        }
        userDate = NSDate().userSafeDate
        databaseDate = NSDate().datebaseSafeDate
        sortDate = ServerValue.timestamp()
        numberPicker.delegate = self
        numberPicker.dataSource = self
        pitchPicker.delegate = self
        pitchPicker.dataSource = self
        dataID()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sendData() {
        self.dataID()
        if teamName == nil || age == nil {
            displayAlert(title: "Oops!", message: "Something went wrong, relog to try to fix the issue!")
        } else {
            self.randomID()
            Refs().statRef.child(randNum).child(leagueName).child(age).child(teamName).childByAutoId().setValue(["Player":"Player#: \(playerNumberPicked!)", "Innings" : "Innings: \(inningNumberPicked!)", "Date":userDate, "Coach":"Coach \(userAcc.lastName!)", "ID":self.ID])
            self.numberPicker.selectRow(0, inComponent: 0, animated: true)
            self.pitchPicker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    func dataID() {
        Refs().statRef.child(randNum).child(leagueName).child(age).child(teamName).observeSingleEvent(of: .value) { (snapshot) in
            self.ID = "\(snapshot.childrenCount + 1)"
        }
    }
    
    func adminChooseTeam() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "adminAgeSelect") as! AdminDataEntryAgeTableViewController
        vc.leagueName = leagueName
        vc.randNum = randNum
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
    func randomID() {
        let pool: NSString = "abcdefghijklmnopqrstuvwxyz1234567890"
        let length = pool.length
        var randomString = ""
        for _ in 0 ..< 9 {
            let rand = arc4random_uniform(UInt32(length))
            var nextChar = pool.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
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
