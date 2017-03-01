//
//  TeamDataSegueViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 2/27/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class TeamDataSegueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ageListTable: UITableView!
    
    let ref = FIRDatabase.database().reference().child("Database")
    var ageList: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.observe(.value, with: {
            snapshot in
            var ageGroups = [String]()
            for ageList in snapshot.children {
                ageGroups.append((ageList as AnyObject).key)
            }
            print(ageGroups)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return ageList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) 
        
        cell.textLabel?.text = ageList[indexPath.row]
        
        return cell
    }

}
