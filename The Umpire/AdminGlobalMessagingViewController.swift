//
//  AminGlobalMessagingViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/23/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import CoreGraphics
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AdminGlobalMessagingViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    let user = FIRAuth.auth()?.currentUser
    let userUID = FIRAuth.auth()?.currentUser?.uid
    let ref = FIRDatabase.database().reference()
    
    var league: String!
    var randNum: String!
    var keyboardHeight: CGFloat = 0
    var textField: UITextField!
    var keyboardStatus: Bool!
    var msgData = [String]()
    var dateData = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var announcementTextField: UITextField!
    @IBAction func submit(_ sender: Any) {
        displayMyAlertMessage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ref.child("UserData").child(userUID!).child("League").observeSingleEvent(of: .value, with: { (snapshot) in
            self.league = snapshot.childSnapshot(forPath: "Name").value as! String!
            self.randNum = snapshot.childSnapshot(forPath: "RandomNumber").value as! String!
            self.dataObserver()
        })
            
        self.view.gradientOfView(withColors: UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.0), UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0))
        
        announcementTextField.delegate = self
        
        createKeyboardTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataObserver() {
        self.ref.child("LeagueData").child(self.randNum).child("Messages").queryLimited(toLast: 15).observe(.value, with: { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                self.msgData.append(snap.childSnapshot(forPath: "Message").value as! String!)
                self.dateData.append(snap.childSnapshot(forPath: "Date").value as! String!)
                self.tableView.reloadData()
            }
            self.msgData.reverse()
            self.dateData.reverse()
        }, withCancel: nil)
    }
    
    @objc func sendMessage() {
        
        if self.keyboardStatus == false {
            self.ref.child("LeagueData").child(self.randNum).child("Messages").childByAutoId().setValue(["Message" as NSString!:self.announcementTextField.text!, "Date" as NSString!:NSDate().userSafeDate, "Status" as NSString!:"Placeholder" as NSString!])
        } else if self.keyboardStatus == true {
            self.ref.child("LeagueData").child(self.randNum).child("Messages").childByAutoId().setValue(["Message" as NSString!:self.textField.text!, "Date" as NSString!:NSDate().userSafeDate, "Status" as NSString!:"Placeholder" as NSString!])
        }
    }
    
    func doneClicked() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.announcementTextField.text = self.textField.text
        self.view.endEditing(true)
        return false
    }
    
    func displayMyAlertMessage()
    {
        let myAlert: UIAlertController!
        
        if self.keyboardStatus == false {
            myAlert = UIAlertController(title: "Your Message", message: "\(self.announcementTextField.text!) \n\nReady to send it?", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { action in
                self.sendMessage()
                self.announcementTextField.text?.removeAll()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
            
            myAlert.addAction(cancelAction)
            myAlert.addAction(okAction)
            
            self.present(myAlert, animated: true, completion: nil)
            
        } else if self.keyboardStatus == true {
            myAlert = UIAlertController(title: "Your Message", message: "\(self.textField.text!) \n\nReady to send it?", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { action in
                self.sendMessage()
                self.textField.text?.removeAll()
                self.textField.endEditing(true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
            
            myAlert.addAction(cancelAction)
            myAlert.addAction(okAction)
            
            self.present(myAlert, animated: true, completion: nil)
        }
        
    }
    
    func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        doneClicked()
    }
    
    func createKeyboardTextField()
    {
        // Register observers for keyboard show/hide states and update height property
        let notificationCenter = NotificationCenter.default
        let mainQueue = OperationQueue.main
        
        notificationCenter.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: mainQueue) { notification in
            if let rectValue = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue
            {
                self.keyboardHeight = rectValue.cgRectValue.size.height
                self.keyboardStatus = true
                self.textField.becomeFirstResponder()
                self.textField.text = self.announcementTextField.text
                print("Keyboard opened")
            }
        }
        
        notificationCenter.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: mainQueue) { notification in
            self.keyboardHeight = 0
            self.keyboardStatus = false
            self.announcementTextField.text = self.textField.text
            print("Keyboard closed")
        }
        
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        
        
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: toolbar.frame.width * 0.79, height: 30))
        textField.delegate = self
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor.white
        textField.borderStyle = UITextBorderStyle.roundedRect
        let textFieldButton = UIBarButtonItem(customView: textField)
        
        let sendBtn = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AdminGlobalMessagingViewController.displayMyAlertMessage))
        
        
        toolbar.setItems([textFieldButton, sendBtn], animated: false)
        announcementTextField.inputAccessoryView = toolbar
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return msgData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AdminMsgTableViewCell
        
        cell.msgLbl.text = msgData[indexPath.row]
        cell.dateLbl.text = dateData[indexPath.row]
        
        
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}
