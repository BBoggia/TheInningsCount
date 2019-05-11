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
    var savePath = UserDefaults.standard.dictionary(forKey: "leagueData") as! [String:[String]]
    let defaults = UserDefaults.standard
    var changesMade: Bool!
    var didRemove: Bool!
    
    @IBAction func addTeam(_ sender: Any) {
        displayTextEntryField()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.teamTableView.delegate = self
        self.teamTableView.dataSource = self
        navBar.title = divSelection!
        changesMade = false
        didRemove = false
        if let val = savePath[divSelection] {
            teams = val
            teamTableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        if teams.count == 0 {
            
        }
        var tmp = savePath
        if changesMade == true {
            var snap = defaults.dictionary(forKey: "leagueData") as! [String:[String]]
            if didRemove == true {
                var snap = UserDefaults.standard.dictionary(forKey: "leagueData") as! [String:[String]]
                snap.removeValue(forKey: divSelection)
                snap[divSelection] = teams
                UserDefaults.standard.set(snap, forKey: "leagueData")
            } else if snap[divSelection] != nil || snap[divSelection] != teams {
                tmp.removeValue(forKey: divSelection)
                tmp[divSelection] = teams
                defaults.set(tmp, forKey: "leagueData")
            } else {
                tmp[divSelection] = teams
                defaults.set(tmp, forKey: "leagueData")
            }
        }
        print(defaults.dictionary(forKey: "leagueData")!)
    }
    
    func displayTextEntryField() {
        
        let myAlert = UIAlertController(title: "Add Team", message: "Enter a team name.", preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addTextField()
        
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            
            if (myAlert.textFields![0].text!.rangeOfCharacter(from: charSet) != nil) {
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
            changesMade = true
            didRemove = true
            print(self.teams)
            teamTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
