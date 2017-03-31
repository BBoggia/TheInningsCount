//
//  Age-TeamDataSelectViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 2/13/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Age_TeamDataSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ageList = [String]()
    var ageToPass: String!
    var userUID = FIRAuth.auth()?.currentUser?.uid as String!
    var league: String!
    var randomNum: String!
    
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var ageListTable: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("User Data").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.value as! String!
            self.populateView()
            self.navBar.title = self.league
        })
        
        self.ageListTable.delegate = self
        self.ageListTable.dataSource = self
        
        if randomNum != nil {
            let myAlert = UIAlertController(title: "IMPORTANT!", message: "This 5 digit code is needed by your coaches when they create an account to be able to use the app. Write it down or it has been copied to your clipboard. \n|\n\(randomNum!)", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) {
                action in
                UIPasteboard.general.string = self.randomNum!
            }
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateView() {
        self.ref.child("LeagueDatabase").child(league).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.ageList.append(snap.key)
                print(self.ageList)
                print(snap.key)
                self.ageListTable.reloadData()
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ageList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ageListTable.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = ageList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = ageListTable.indexPathForSelectedRow
        let currentCell = ageListTable.cellForRow(at: indexPath!) as UITableViewCell!
        
        ageToPass = currentCell?.textLabel?.text
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dataEntry") as! b810DataEntryViewController
        vc.age = ageToPass
        vc.leagueName = league
        navigationController?.pushViewController(vc,animated: true)
    }
}
