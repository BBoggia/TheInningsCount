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
    var textLabelTeams = ["test"]
    var ageGroups = [String]()
    @IBOutlet weak var teamDisplay: UILabel!
    
    @IBOutlet weak var teamName: UITextField!
    
    @IBAction func addTeam(_ sender: Any) {
        
        if (teamName.text?.contains("$"))! || (teamName.text?.contains("/"))! || (teamName.text?.contains("\\"))! || (teamName.text?.contains("#"))! || (teamName.text?.contains("["))! || (teamName.text?.contains("]"))! || (teamName.text?.contains("."))! {
            displayAlert(title: "Oops!", message: "Your age group cannot contain the following characters \n '$' '.' '/' '\\' '#' '[' ']'")
        } else {
            textLabelTeams.append(teamName.text!)
            teamDisplay.text = textLabelTeams.joined(separator: ", ")
            teamName.text?.removeAll()
        }
    }
    
    @IBAction func removeTeam(_ sender: Any) {
        if textLabelTeams.count < 1 {
            
            displayAlert(title: "Oops!", message: "There are no more teams in the list.")
            
        } else {
            textLabelTeams.removeLast()
            teamDisplay.text = textLabelTeams.joined(separator: ", ")
        }
    }
    
    @IBAction func createTeams(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "acCreate") as! CompleteLeagueCreationViewController
        vc.leagueName = leagueName as String
        vc.email = email as String
        vc.password = password as String
        vc.teams = textLabelTeams as Array
        vc.ageGroups = ageGroups as Array
        navigationController?.pushViewController(vc,animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.teamName.delegate = self
        
        textLabelTeams.removeAll()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        teamName.inputAccessoryView = toolBar
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            teamName.heightAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    @objc func doneClicked() {
        self.view.endEditing(true)
    }
}
