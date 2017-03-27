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
    var textLabelTeams = ["test", "test"]
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
        
        performSegue(withIdentifier: "fromTC", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.teamName.delegate = self
        self.adminTeam.delegate = self
        
        textLabelTeams.removeAll()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromTC" {
            var completeVC: CompleteLeagueCreationViewController
            
            completeVC = segue.destination as! CompleteLeagueCreationViewController
            completeVC.leagueName = leagueName as String
            completeVC.email = email as String
            completeVC.password = password as String
            completeVC.teams = textLabelTeams as Array
            completeVC.adminTeam = adminsTeam as String
        }
    }
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
}
