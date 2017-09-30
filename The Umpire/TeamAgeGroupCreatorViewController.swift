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

class TeamAgeGroupCreatorViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var leagueName: String!
    var email: String!
    var password: String!
    var selectedAge: String!
    var ageGroups = [String]()
    var teamLists = [String: [String]]()
    
    @IBOutlet weak var ageTableView: UITableView!
    
    @IBAction func addAgeBtn(_ sender: Any) {
        displayTextEntryField(title: "Age Group Name", userMessage: "Enter the name of an age group then press confirm.")
    }
    
    @IBAction func removeGroup(_ sender: Any) {
        
        
    }
    
    @IBAction func createGroups(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "teamCreate") as! TeamNameViewController
        vc.leagueName = leagueName as String
        vc.email = email as String
        vc.password = password as String
        vc.ageGroups = ageGroups as Array
        navigationController?.pushViewController(vc,animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ageTableView.delegate = self
        self.ageTableView.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        displayMyAlertMessage(title: "Create a Division", userMessage: "Here if your league has more than one age group or division you can add them otherwise just make one. To create a division use the + icon in the top right corner. To add individual teams just select one from your list and start adding!")
        
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
    
    func displayMyAlertMessage(title:String, userMessage:String)
    {
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    func displayTextEntryField(title:String, userMessage:String)
    {
        
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        myAlert.addTextField()
        
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            
            if (myAlert.textFields![0].text!.contains("$")) ||
                (myAlert.textFields![0].text!.contains("/")) ||
                (myAlert.textFields![0].text!.contains("\\")) ||
                (myAlert.textFields![0].text!.contains("#")) ||
                (myAlert.textFields![0].text!.contains("[")) ||
                (myAlert.textFields![0].text!.contains("]")) ||
                (myAlert.textFields![0].text!.contains(".")) {
                self.displayMyAlertMessage(title: "Oops!", userMessage: "Your age group cannot contain the following characters \n '$' '.' '/' '\\' '#' '[' ']'")
            } else {
                self.ageGroups.append(myAlert.textFields![0].text!)
                print(myAlert.textFields![0].text!)
                self.ageTableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ageGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ageTableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = ageGroups[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = ageTableView.indexPathForSelectedRow
        let currentCell = ageTableView.cellForRow(at: indexPath!) as UITableViewCell!
        
        selectedAge = currentCell?.textLabel?.text
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            var deletedAge = ageGroups[indexPath.row] as String!
            
            for i in teamLists.keys {
                
                let key = i as String
                if key == deletedAge {
                    self.teamLists.removeValue(forKey: deletedAge!)
                }
            }
            
            self.ageGroups.remove(at: indexPath.row)
            
            ageTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
