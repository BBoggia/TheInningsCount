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

class AdminGlobalMessagingViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    var user: User!
    var userUID: String!
    
    var league: String!
    var randNum: String!
    var msgData = [String]()
    var dateData = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgView: UIView!
    
    let messageInputContainerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    let sendButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor.init(red: 0, green: 137, blue: 249, alpha: 1)
        button.titleLabel?.textColor = titleColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid
        
        let tap = UITapGestureRecognizer(target: self, action: {#selector(textFieldShouldReturn)}())
        tap.cancelsTouchesInView = false
        view.addSubview(messageInputContainerView)
        messageInputContainerView.frame = CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44)
        tableView.delegate = self
        tableView.dataSource = self
        inputTextField.delegate = self
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        
        dataObserver()
            
        self.view.gradientOfView(withColors: UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.0), UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0))
        setupInputComponents()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isDescendant(of: sendButton))! {
            return false
        } else {
            return true
        }
    }
    
    @objc func send (sender: UIButton) {
        displayMyAlertMessage()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        animateTextField()
        return true
    }
    
    func animateTextField() {
        UIView.animate(withDuration: 0.27, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            self.messageInputContainerView.frame = CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44)
        }) { (completed) in }
    }
    
    private func setupInputComponents() {
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        
        inputTextField.frame = CGRect(x: 8, y: 3, width: messageInputContainerView.frame.width * 0.75, height: 38)
        sendButton.frame = CGRect(x: inputTextField.frame.width + 10, y: 4, width: messageInputContainerView.frame.width * 0.2, height: 36)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            let keyboardInfo = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            messageInputContainerView.frame = CGRect(x: 0, y: self.view.frame.height - 44 - (keyboardInfo?.height)!, width: self.view.frame.width, height: 44)
        }
    }
    
    func dataObserver() {
        self.dateData.removeAll()
        self.msgData.removeAll()
        Refs().dataRef.child(self.randNum).child("Messages").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.msgData.append((snap.childSnapshot(forPath: "Message").value as! String?)!)
                self.dateData.append((snap.childSnapshot(forPath: "Date").value as! String?)!)
                self.tableView.reloadData()
            }
            self.msgData.reverse()
            self.dateData.reverse()
            self.tableView.reloadData()
        }, withCancel: nil)
    }
    
    func displayMyAlertMessage() {
        let myAlert: UIAlertController!
        
        myAlert = UIAlertController(title: "Your Message", message: "\(self.inputTextField.text!)\n\nReady to send it?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.default) { action in
            
            Refs().dataRef.child(self.randNum).child("Messages").childByAutoId().setValue(["Message":self.inputTextField.text!, "Date":NSDate().userSafeDate, "Status":"Placeholder" as String?])
            self.dataObserver()
            self.inputTextField.text?.removeAll()
            self.view.endEditing(true)
            self.animateTextField()
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
        myAlert.addAction(cancelAction)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
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
