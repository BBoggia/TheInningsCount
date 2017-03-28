//
//  TeamAgeGroupCreatorViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/27/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TeamAgeGroupCreatorViewController: UIViewController, UITextFieldDelegate {
    
    var leagueName: String!
    var email: String!
    var password: String!
    var adminTeam = ""
    var textLabelGroups = [""]
    var teams = [String]()
    
    @IBOutlet weak var groupDisplay: UILabel!
    @IBOutlet weak var groupTextField: UITextField!
    
    @IBAction func addGroup(_ sender: Any) {
        textLabelGroups.append(groupTextField.text!)
        groupDisplay.text = textLabelGroups.joined(separator: ", ")
        groupTextField.text?.removeAll()
    }
    
    @IBAction func removeGroup(_ sender: Any) {
        if textLabelGroups.count < 1 {
            
            displayMyAlertMessage(title: "Oops!", userMessage: "There are no more teams in the list.")
            
        } else {
            textLabelGroups.removeLast()
            groupDisplay.text = textLabelGroups.joined(separator: ", ")
        }
    }
    
    @IBAction func createGroups(_ sender: Any) {
        performSegue(withIdentifier: "fromAC", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupTextField.delegate = self
        
        textLabelGroups.removeAll()
        
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
        if segue.identifier == "fromAC" {
            var completeVC: CompleteLeagueCreationViewController
            
            completeVC = segue.destination as! CompleteLeagueCreationViewController
            completeVC.leagueName = leagueName as String
            completeVC.email = email as String
            completeVC.password = password as String
            completeVC.teams = teams as Array
            completeVC.adminTeam = adminTeam as String
            completeVC.ageGroups = textLabelGroups as Array
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
