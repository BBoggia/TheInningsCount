//
//  TeamCreationViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 9/19/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit

class TeamCreationViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var teamTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var leagueName: String!
    var teams = [String]()
    var selectedTeam: String!
    var divSelection: String!
    var defaults = UserDefaults.standard
    var changesMade: Bool!
    
    @IBAction func addTeam(_ sender: Any) {
        
        displayTextEntryField(title: "Add a Team")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let save = defaults.array(forKey: "leagueData")! as! [[String:[String]]]
        
        for i in save {
            
            if i[divSelection] != nil {
                
                self.teams = i[divSelection]!
                self.teamTableView.reloadData()
            }
        }
        
        self.teamTableView.delegate = self
        self.teamTableView.dataSource = self
        navBar.title = divSelection!
        changesMade = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if teams.count >= 1 && changesMade == true {
            
            var divDict = [String:[String]]()
            divDict = [divSelection:teams]
            var newData = defaults.array(forKey: "leagueData") as! [[String : [String]]]
            newData.append(divDict)
            defaults.set(newData, forKey: "leagueData")
        }
        
        print(defaults.array(forKey: "leagueData") as? [String] ?? String())
        
    }
    
    func displayTextEntryField(title:String) {
        
        let myAlert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addTextField()
        
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            
            if (myAlert.textFields![0].text!.contains("$")) ||
                (myAlert.textFields![0].text!.contains("/")) ||
                (myAlert.textFields![0].text!.contains("\\")) ||
                (myAlert.textFields![0].text!.contains("#")) ||
                (myAlert.textFields![0].text!.contains("[")) ||
                (myAlert.textFields![0].text!.contains("]")) ||
                (myAlert.textFields![0].text!.contains(".")) {
                self.displayAlert(title: "Oops!", message: "Your team name cannot contain the following characters. \n '$' '.' '/' '\\' '#' '[' ']'")
            } else if (myAlert.textFields![0].text!.isEmpty) {
                self.displayAlert(title: "Oops!", message: "You cannot leave a teams name blank.")
            } else if self.teams.contains(myAlert.textFields![0].text!) {
                self.displayAlert(title: "Oops!", message: "One or more teams cannot share the same name.")
            } else {
                self.teams.append(myAlert.textFields![0].text!)
                print(self.teams)
                self.teamTableView.reloadData()
                self.changesMade = true
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
        
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = teamTableView.dequeueReusableCell(withIdentifier: "createTeamCell")
        cell?.textLabel?.text = teams[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = teamTableView.indexPathForSelectedRow
        let currentCell = teamTableView.cellForRow(at: indexPath!)
        
        selectedTeam = currentCell?.textLabel?.text
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.teams.remove(at: indexPath.row)
            teamTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
