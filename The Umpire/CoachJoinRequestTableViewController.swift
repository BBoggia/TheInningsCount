//
//  CoachJoinRequestTableViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 7/21/18.
//  Copyright © 2018 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class CoachJoinRequestTableViewController: UITableViewController {
    
    var tableList: [JoinRequest] = []
    var queuedList: [JoinRequest] = []
    var leagueNumber: String!
    var leagueName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        dataObserver()
    }
    
    func dataObserver() {
        Refs().dataRef.child(leagueNumber).child("Requests").observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                var request = JoinRequest()
                request.dateAccepted = ""
                request.dateRequested = snap.childSnapshot(forPath: "DateRequested").value as? String
                request.div = snap.childSnapshot(forPath: "Division").value as? String
                request.email = snap.childSnapshot(forPath: "Email").value as? String
                request.name = snap.childSnapshot(forPath: "Name").value as? String
                request.requestStatus = snap.childSnapshot(forPath: "RequestStatus").value as? Bool
                request.team = snap.childSnapshot(forPath: "Team").value as? String
                request.uid = snap.key
                self.tableList.append(request)
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CoachJoinRequestTableViewCell
        cell.name.text = tableList[indexPath.row].name
        cell.email.text = tableList[indexPath.row].email
        cell.division.text = tableList[indexPath.row].div
        cell.team.text = tableList[indexPath.row].team
        cell.backgroundColor = UIColor.white
        for i in queuedList {
            if cell.name.text == i.name && cell.email.text == i.email {
                cell.backgroundColor = UIColor.cyan
            }
        }
        return cell
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deny = UIContextualAction(style: .normal, title: "-") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.queuedList.append(self.tableList[indexPath.row])
            let toRemove = self.queuedList.map { $0.uid }
            let newList = self.tableList.filter  { !toRemove.contains($0.uid) }
            self.tableList = newList
            for i in self.queuedList {
                Refs().dataRef.child(self.leagueNumber).child("Requests").child(i.uid).removeValue()
                Refs().usrRef.child(i.uid).child("Requests").child(self.leagueNumber).removeValue()
                self.tableView.reloadData()
            }
            self.queuedList.removeAll()
            self.tableView.reloadData()
        }
        deny.backgroundColor = UIColor.red
        let queueAdd = UIContextualAction(style: .normal, title: "Q+") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.queuedList.append(self.tableList[indexPath.row])
            self.tableView.reloadData()
        }
        queueAdd.backgroundColor = UIColor.blue
        let queueRemove = UIContextualAction(style: .normal, title: "Q-") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.queuedList.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        queueRemove.backgroundColor = UIColor.orange
        let accept = UIContextualAction(style: .normal, title: "+") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.queuedList.append(self.tableList[indexPath.row])
            let toRemove = self.queuedList.map { $0.uid }
            let newList = self.tableList.filter  { !toRemove.contains($0.uid) }
            self.tableList = newList
            for i in self.queuedList {
                Refs().dataRef.child(self.leagueNumber).child("CoachInfo").child(i.uid).setValue(["Name":i.name, "Email":i.email, "AdminStatus":false, "OwnerStatus":false, "Division":i.div, "Team":i.team, "DateAccepted":NSDate().userSafeDate, "DateRequested":i.dateRequested])
                Refs().usrRef.child(i.uid).child("Leagues").child(self.leagueNumber).setValue(["AdminStatus":false, "Division":i.div, "Team":i.team, "LeagueName":self.leagueName, "OwnerStatus":false])
                Refs().dataRef.child(self.leagueNumber).child("Requests").child(i.uid).removeValue()
                Refs().usrRef.child(i.uid).child("Requests").child(self.leagueNumber).removeValue()
                self.tableView.reloadData()
            }
            self.queuedList.removeAll()
            self.tableView.reloadData()
        }
        accept.backgroundColor = UIColor.green
        for i in queuedList {
            if i.name == tableList[indexPath.row].name && i.email == tableList[indexPath.row].email {
                return UISwipeActionsConfiguration(actions: [accept, queueRemove, deny])
            }
        }
        
        return UISwipeActionsConfiguration(actions: [accept, queueAdd, deny])
    }
}

class CoachJoinRequestTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var division: UILabel!
    @IBOutlet weak var team: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
