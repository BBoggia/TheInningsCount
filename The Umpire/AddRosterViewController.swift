//
//  AddRosterViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/7/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AddRosterViewController: UIViewController, UIPickerViewDelegate {
    
    var userUID: String!
    var teamName: String!
    var leagueName: String!
    var rosterList = [String]()
    var currentSelection: String!
    var pickerDataString = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9","10","11", "12", "13", "14", "15", "16", "17", "18", "19","20","21", "22", "23", "24", "25", "26", "27", "28", "29","30","31", "32", "33", "34", "35", "36", "37", "38", "39","40","41", "42", "43", "44", "45", "46", "47", "48", "49","50","51", "52", "53", "54", "55", "56", "57", "58", "59","60","61", "62", "63", "64", "65", "66", "67", "68", "69","70","71", "72", "73", "74", "75", "76", "77", "78", "79","80","81", "82", "83", "84", "85", "86", "87", "88", "89","90","91", "92", "93", "94", "95", "96", "97", "98", "99"]

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var playerDisplay: UILabel!
    @IBOutlet weak var numPicker: UIPickerView!
    @IBAction func add(_ sender: Any) {
        rosterList.append("Pitcher: \(currentSelection!)")
        playerDisplay.text = rosterList.joined(separator: ", ")
    }
    @IBAction func remove(_ sender: Any) {
        if rosterList.count == 0 {
            
        } else {
            rosterList.removeLast()
            playerDisplay.text = rosterList.joined(separator: ", ")
        }
    }
    @IBAction func submit(_ sender: Any) {
        for child in rosterList {
            Refs().ref.child("LeagueTeamLists").child(leagueName).child(teamName).child(child).setValue("0")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userUID = Auth.auth().currentUser?.uid as String?
        numPicker.delegate = self

        Refs().usrRef.child(userUID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.teamName = snapshot.childSnapshot(forPath: "Team").value as! String?
            self.leagueName = snapshot.childSnapshot(forPath: "League").value as! String?
            self.navBar.title = self.leagueName
            self.fillList()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillList() {
        Refs().ref.child("LeagueTeamLists").child(leagueName).child(teamName).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.childrenCount >= 1 {
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    self.rosterList.append(snap.key)
                }
            }
        })
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataString.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataString[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSelection = pickerDataString[row]
    }

}
