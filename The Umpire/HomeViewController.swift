//
//  HomeViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/18/18.
//  Copyright © 2018 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func lastLeague(_ sender: Any) {
        if let lastLeague = defaults.dictionary(forKey: userAcc.uid) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mainHub") as! mainHubViewController
            vc.leagueName = lastLeague["league"] as? String
            vc.leagueNum = lastLeague["number"] as! String
            vc.Division = lastLeague["division"] as? String
            vc.team = lastLeague["team"] as? String
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            displayAlert(title: "Oops!", message: "It looks like you haven't viewed a league yet on this device.")
        }
    }
    @IBAction func yourLeagues(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dynamicPopup") as! ReusablePopupViewController
        vc.sender = "YourLeagues"
        self.addChildViewController(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    @IBAction func joinLeague(_ sender: Any) {
        let alert = UIAlertController(title: "Join a League", message: "Enter the 5 digit pin number for the league you would like to request to join.", preferredStyle: .alert)
        alert.addTextField()
        let send = UIAlertAction(title: "Send", style: .default) { action in
            Refs().dataRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.childSnapshot(forPath: alert.textFields![0].text!).exists() {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "toAgeSelect") as! SignupAgeTableViewController
                    vc.leagueCode = alert.textFields![0].text!
                    vc.uid = userAcc.uid
                    vc.alreadyHaveAccCheck = true
                    self.navigationController?.pushViewController(vc,animated: true)
                } else {
                    self.displayAlert(title: "Oops!", message: "The league code you entered does not exist.")
                }
            })
            for i in userAcc.leagues {
                if i.leagueNumber == alert.textFields![0].text {
                    self.displayAlert(title: "Oops!", message: "You already are a member of that league!")
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancel)
        alert.addAction(send)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func createLeague(_ sender: Any) {
        let alert = UIAlertController(title: "Create a League", message: "Enter the name of your new league.", preferredStyle: .alert)
        alert.addTextField()
        let ok = UIAlertAction(title: "Ok", style: .default) { action in
            if alert.textFields![0].text!.isEmpty {
                self.displayAlert(title: "Oops!", message: "Your league name cannot be empty!")
            } else if alert.textFields![0].text!.rangeOfCharacter(from: charSet) != nil {
                self.displayAlert(title: "Oops!", message: "Your league name cannot contain the following characters. \n '$' '.' '/' '\\' '#' '[' ']'")
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ageCreate") as! TeamAgeGroupCreatorViewController
                vc.leagueName = alert.textFields![0].text
                self.navigationController?.pushViewController(vc,animated: true)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func leagueAnnouncements(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dynamicPopup") as! ReusablePopupViewController
        vc.sender = "LeagueAnnouncements"
        self.addChildViewController(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    @IBAction func settings(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dynamicPopup") as! ReusablePopupViewController
        vc.sender = "Settings"
        self.addChildViewController(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    
    @IBAction func logOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        self.performSegue(withIdentifier: "signoutFromHome", sender: nil)
    }
    
    @IBOutlet weak var yourLeagueOutlet: UIButton!
    @IBOutlet weak var lastLeagueOutlet: UIButton!
    @IBOutlet weak var joinLeagueOutlet: UIButton!
    @IBOutlet weak var createLeagueOutlet: UIButton!
    @IBOutlet weak var leagueAnnouncementsOutlet: UIButton!
    @IBOutlet var popUpView: UIView!
    
    var leagueMsgs = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.yourLeagueOutlet.titleLabel?.font = .boldSystemFont(ofSize: 38)
            self.lastLeagueOutlet.titleLabel?.font = .boldSystemFont(ofSize: 38)
            self.joinLeagueOutlet.titleLabel?.font = .boldSystemFont(ofSize: 38)
            self.createLeagueOutlet.titleLabel?.font = .boldSystemFont(ofSize: 38)
            self.leagueAnnouncementsOutlet.titleLabel?.font = .boldSystemFont(ofSize: 38)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        leagueMsgs.removeAll()
        userAcc.leagues.removeAll()
        retriveStats()
        populateTableView()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func retriveStats() {
        userAcc = UsrAcc(user: Auth.auth().currentUser, uid: Auth.auth().currentUser?.uid, email: Auth.auth().currentUser?.email, firstName: "", lastName: "", leagues: [leagueInfo()])
        Refs().usrRef.child(userAcc.uid).observeSingleEvent(of: .value) { (snapshot) in
            userAcc.firstName = snapshot.childSnapshot(forPath: "FirstName").value as! String?
            userAcc.lastName = snapshot.childSnapshot(forPath: "LastName").value as! String?
            if snapshot.childSnapshot(forPath: "Leagues").hasChildren() {
                for child in snapshot.childSnapshot(forPath: "Leagues").children {
                    let snap = child as? DataSnapshot
                    let league = leagueInfo(leagueName: (snap?.childSnapshot(forPath: "LeagueName").value as! String?)!, leagueNumber: snap?.key, division: (snap?.childSnapshot(forPath: "Division").value as! String?)!, team: (snap?.childSnapshot(forPath: "Team").value as! String?)!, isAdmin: (snap?.childSnapshot(forPath: "AdminStatus").value as! Bool?)!)
                    userAcc.leagues.append(league)
                }
            } else {
                let i = leagueInfo()
                userAcc.leagues.append(i)
                userAcc.leagues.removeAll()
            }
        }
    }
    
    func populateTableView() {
        if userAcc.leagues.count > 0 && userAcc.leagues[0].leagueName != nil {
            for league in userAcc.leagues {
                Refs().dataRef.child(league.leagueNumber).observeSingleEvent(of: .value) { (snapshot) in
                    var msgArray = [String]()
                    for msgs in snapshot.childSnapshot(forPath: "Messages").children {
                        let snap = msgs as? DataSnapshot
                        msgArray.append((snap?.key)!)
                    }
                    msgArray.reverse()
                    do {
                        msgArray.removeSubrange(5...)
                    }
                    for index in 0...4 {
                        self.leagueMsgs.append(["name":snapshot.childSnapshot(forPath: "LeagueName").value as! String, "date": snapshot.childSnapshot(forPath: msgArray[index]).childSnapshot(forPath: "Date").value as! String, "message":snapshot.childSnapshot(forPath: msgArray[index]).childSnapshot(forPath: "Message").value as! String])
                    }
                }
            }
            leagueMsgs.sort { (($0 )["date"])! < (($1 )["date"])! }
            tableView.reloadData()
        } else {
            leagueMsgs.append(["name":"", "date":"", "message":"It looks like there aren't any new messages."])
            tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leagueMsgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AdminMsgTableViewCell
        
        cell.leagueLbl.text = leagueMsgs[indexPath.row]["name"]
        cell.homeDateLbl.text = leagueMsgs[indexPath.row]["date"]
        cell.homeMsgLbl.text = leagueMsgs[indexPath.row]["message"]
        return cell
    }
}
