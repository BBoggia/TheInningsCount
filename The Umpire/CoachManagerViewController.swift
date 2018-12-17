//
//  CoachManagerTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/9/18.
//  Copyright © 2018 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class CoachManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var user: User!
    var leagueName: String!
    var leagueCode: String!
    var pickerList: [String] = []
    var selectedRow: String!
    var coachList: [Coach] = []
    var chosenUID: String!
    @IBOutlet weak var tableView: UITableView!
    var pickerView: UIPickerView!
    @IBAction func requestBtn(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "coachRequests") as! CoachJoinRequestTableViewController
        vc.leagueNumber = leagueCode
        vc.leagueName = leagueName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        Refs().dataRef.child(leagueCode).child("CoachInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            self.coachList.removeAll()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                var coach = Coach()
                coach.div = snap.childSnapshot(forPath: "Division").value as? String
                coach.team = snap.childSnapshot(forPath: "Team").value as? String
                coach.email = snap.childSnapshot(forPath: "Email").value as? String
                coach.name = snap.childSnapshot(forPath: "Name").value as? String
                if let adminStatus: Bool = snap.childSnapshot(forPath: "AdminStatus").value as? Bool {
                    coach.isAdmin = adminStatus
                } else {
                    print("Error setting coach object child 'isAdmin'.")
                }
                coach.isOwner = snap.childSnapshot(forPath: "OwnerStatus").value as? Bool
                coach.uid = snap.key
                self.coachList.append(coach)
                self.tableView.reloadData()
            }
        })
    }
    
    func coachManagerAlert(title: String, chosenUID: String, name: String) {
        let alert = UIAlertController(title: title, message: "What would you like to do?", preferredStyle: .alert)
        
        let changeDivision = UIAlertAction(title: "Change Division", style: .default) { action in self.alertOptions(option: 0, name: name, alt: false)}
        let changeTeam = UIAlertAction(title: "Change Team", style: .default) { action in self.alertOptions(option: 0, name: name, alt: true)}
        let setAdmin = UIAlertAction(title: "Add/Remove Admin", style: .destructive) { action in self.alertOptions(option: 2, name: name, alt: false)}
        let removeCoach = UIAlertAction(title: "Remove Coach", style: .destructive) { action in self.alertOptions(option: 3, name: name, alt: false)}
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(changeDivision)
        alert.addAction(changeTeam)
        alert.addAction(setAdmin)
        alert.addAction(removeCoach)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertOptions(option: Int, name: String, alt: Bool) {
        switch option {
        case 0:
            self.pickerList.removeAll()
            let alert = UIAlertController(title: "Change Division", message: "Select \(name)'s new division.\n\n\n\n\n\n\n", preferredStyle: .alert)
            Refs().statRef.child(self.leagueCode).child(leagueName).observeSingleEvent(of: .value) { (snapshot) in
                for i in snapshot.children {
                    let snap = i as! DataSnapshot
                    self.pickerList.append(snap.key)
                }
                self.pickerView.dataSource = self
                self.pickerView.delegate = self
                self.pickerView.reloadAllComponents()
            }
            self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: 260, height: 142))
            let done = UIAlertAction(title: "Done", style: .default) { action in
                for i in self.coachList {
                    if i.uid == self.chosenUID {
                        Refs().dataRef.child(self.leagueCode).child("CoachInfo").child((i.uid)!).child("Division").setValue(self.selectedRow)
                        Refs().usrRef.child((i.uid)!).child("Leagues").child(self.leagueCode).child("Division").setValue(self.selectedRow)
                        self.dataObserver()
                        self.alertOptions(option: 1, name: name, alt: true)
                        break
                    }
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.view.addSubview(self.pickerView)
            alert.addAction(done)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        case 1:
            self.pickerList.removeAll()
            let chosenDiv = self.selectedRow
            self.selectedRow = ""
            let alert = UIAlertController(title: "Change Team", message: "Select \(name)'s new team in the \(chosenDiv!) division.\n\n\n\n\n\n\n", preferredStyle: .alert)
            Refs().statRef.child(self.leagueCode).child(leagueName).child(chosenDiv!).observeSingleEvent(of: .value) { (snapshot) in
                for i in snapshot.children {
                    let snap = i as! DataSnapshot
                    self.pickerList.append(snap.key)
                }
                self.pickerView.dataSource = self
                self.pickerView.delegate = self
                self.pickerView.reloadAllComponents()
            }
            self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: 260, height: 142))
            let done = UIAlertAction(title: "Done", style: .default) { action in
                for i in self.coachList {
                    if i.uid == self.chosenUID {
                        Refs().dataRef.child(self.leagueCode).child("CoachInfo").child((i.uid)!).child("Team").setValue(self.selectedRow)
                        Refs().usrRef.child((i.uid)!).child("Leagues").child(self.leagueCode).child("Team").setValue(self.selectedRow)
                        self.dataObserver()
                        break
                    } else {
                        print("no")
                    }
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.view.addSubview(self.pickerView)
            alert.addAction(done)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        case 2:
            self.pickerList.removeAll()
            let alert = UIAlertController(title: "Add/Remove Admin", message: "Are you sure you want to add/remove \(name) as an admin?.", preferredStyle: .alert)
            let addAdmin = UIAlertAction(title: "Add/Remove", style: .default) { action in
                for i in self.coachList {
                    if i.uid == self.chosenUID {
                        if i.isOwner == true {
                            self.displayAlert(title: "Oops!", message: "Your can't remove the owner's admin privileges.")
                        } else {
                            var tmp = i.isAdmin
                            tmp = !tmp!
                            
                            Refs().dataRef.child(self.leagueCode).child("CoachInfo").child((i.uid)!).child("AdminStatus").setValue(tmp)
                            Refs().usrRef.child((i.uid)!).child("Leagues").child(self.leagueCode).child("AdminStatus").setValue(tmp)
                        }
                        self.dataObserver()
                        break
                    }
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(addAdmin)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        case 3:
            self.pickerList.removeAll()
            let alert = UIAlertController(title: "Remove Coach", message: "Are you sure you want to remove \(name) as a coach in your league?", preferredStyle: .alert)
            let removeCoach = UIAlertAction(title: "Remove Coach", style: .default) { action in
                for i in self.coachList {
                    if i.uid == self.chosenUID {
                        if i.isOwner == true {
                            self.displayAlert(title: "Oops!", message: "Your can't remove the owner of the league.")
                        } else {
                            if i.isAdmin == true {
                                self.displayAlert(title: "Oops!", message: "You can't remove admins from the league.")
                            } else {
                                Refs().dataRef.child(self.leagueCode).child("CoachInfo").child((i.uid)!).removeValue()
                                Refs().usrRef.child((i.uid)!).child("Leagues").child(self.leagueCode).removeValue()
                            }
                        }
                        self.dataObserver()
                        break
                    }
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.view.addSubview(self.pickerView)
            alert.addAction(removeCoach)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return coachList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CoachManagerTableViewCell
        
        cell.name.text = coachList[indexPath.row].name
        cell.email.text = coachList[indexPath.row].email
        if coachList[indexPath.row].isAdmin == true {
            cell.division.text = "No Division"
        } else {
            cell.division.text = coachList[indexPath.row].div
        }
        if coachList[indexPath.row].isAdmin == true {
            cell.team.text = "No Team"
        } else {
            cell.team.text = coachList[indexPath.row].team
        }
        if coachList[indexPath.row].isAdmin == true {
            cell.adminStatus.text = "A"
        } else {
            cell.adminStatus.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coachManagerAlert(title: "Coach " + (coachList[indexPath.row].name)!, chosenUID: (coachList[indexPath.row].uid)!, name: (coachList[indexPath.row].name)!)
        chosenUID = coachList[indexPath.row].uid
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = pickerList[row]
    }
}

class CoachManagerTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var division: UILabel!
    @IBOutlet weak var team: UILabel!
    @IBOutlet weak var adminStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
