//
//  TeamNameViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/25/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TeamNameViewController: UIViewController, UITextFieldDelegate {
    
    var leagueName: String!
    var email: String!
    var password: String!
    var adminsTeam = ""
    var textLabelTeams = ["test"]
    @IBOutlet weak var teamDisplay: UILabel!
    
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var adminTeam: UITextField!
    
    @IBAction func addTeam(_ sender: Any) {
        textLabelTeams.append(teamName.text!)
        teamDisplay.text = textLabelTeams.joined(separator: ", ")
        teamName.text?.removeAll()
    }
    
    @IBAction func removeTeam(_ sender: Any) {
        if textLabelTeams.count < 1 {
            
            displayMyAlertMessage(title: "Oops!", userMessage: "There are no more teams in the list.")
            
        } else {
            textLabelTeams.removeLast()
            teamDisplay.text = textLabelTeams.joined(separator: ", ")
        }
    }
    
    @IBAction func createTeams(_ sender: Any) {
        adminsTeam = adminTeam.text!
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ageCreate") as! TeamAgeGroupCreatorViewController
        vc.leagueName = leagueName as String
        vc.email = email as String
        vc.password = password as String
        vc.teams = textLabelTeams as Array
        vc.adminTeam = adminsTeam as String
        navigationController?.pushViewController(vc,animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.teamName.delegate = self
        self.adminTeam.delegate = self
        
        textLabelTeams.removeAll()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        teamName.inputAccessoryView = toolBar
        adminTeam.inputAccessoryView = toolBar
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func doneClicked() {
        self.view.endEditing(true)
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
}
