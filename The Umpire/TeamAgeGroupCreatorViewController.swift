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
            groupDisplay.text = textLabelGroups.joined(separator: "\n")
        }
    }
    
    @IBAction func createGroups(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "acCreate") as! CompleteLeagueCreationViewController
        vc.leagueName = leagueName as String
        vc.email = email as String
        vc.password = password as String
        vc.teams = teams as Array
        vc.adminTeam = adminTeam as String
        vc.ageGroups = textLabelGroups as Array
        navigationController?.pushViewController(vc,animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupTextField.delegate = self
        
        textLabelGroups.removeAll()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        groupTextField.inputAccessoryView = toolBar
        
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
