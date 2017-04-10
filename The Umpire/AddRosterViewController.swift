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
    
    var ref = FIRDatabase.database().reference()
    var userUid = FIRAuth.auth()?.currentUser?.uid as String!
    
    var teamName: String!
    var leagueName: String!
    var rosterList = [String]()
    var pickerDataInt = [0...100]
    var pickerDataString = [String]()

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var playerDisplay: UILabel!
    @IBOutlet weak var numPicker: UIPickerView!
    @IBAction func add(_ sender: Any) {
    }
    @IBAction func remove(_ sender: Any) {
    }
    @IBAction func submit(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numPicker.delegate = self
        
        pickerDataString = pickerDataInt.map({String(describing: $0) })

        let teamNameRef = ref.child("User Data").child(userUid!)
        teamNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.teamName = snapshot.childSnapshot(forPath: "Team").value as! String!
            self.leagueName = snapshot.childSnapshot(forPath: "League").value as! String!
            self.navBar.title = self.leagueName
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataInt.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataString[row]
    }

}
