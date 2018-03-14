//
//  ViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 12/1/16.
//  Copyright © 2016 PineTree Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {
    
    var ref : DatabaseReference?
    var user: User?
    var userUID: String!
    var effect: UIVisualEffect!
    
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var viewInScroll: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func helpButton(_ sender: Any) { //Opens help button
        openPopUp()
    }
    @IBAction func close(_ sender: UIButton) { //Closes help button
        closePopUp()
    }
    @IBAction func logInButton(_ sender: Any) { //Login button
        if self.emailField.text == "" || self.passwordField.text == "" { //Checks fields
            let alertController = UIAlertController(title: "Oops!", message: "One of the text fields is empty!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { //Authenticates user
                (user, error) in
                
                if error == nil {
                    
                    let defaults = UserDefaults.standard
                    
                    defaults.setValue(user?.uid, forKey: "uid")
                    
                    self.userUID = user?.uid
                    self.emailField.text = ""
                    self.passwordField.text = ""
                    
                    self.performSegue(withIdentifier: "toMC", sender: nil)
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, //Displayes error preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            })
        }
    }
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        
        //Help menu constraints
        popUpView.layer.cornerRadius = 5
        scrollView.layer.cornerRadius = 5
        viewInScroll.layer.cornerRadius = 5
        closeButton.layer.cornerRadius = 5
        visualEffectView.layer.bounds.size.height = 0
        visualEffectView.layer.bounds.size.width = 0
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, viewInScroll.layer.bounds.height - 370, 0)
        
        initialLaunch() //Checks if is initial launch
        
        emailField.delegate = self
        passwordField.delegate = self
        
        let firebaseAuth = Auth.auth() //Verifys no user is logged in
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        myLabel.layer.masksToBounds = true
        myLabel.layer.cornerRadius = 10
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        emailField.inputAccessoryView = toolBar
        passwordField.inputAccessoryView = toolBar
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            appTitle.font = UIFont(name: appTitle.font.fontName, size: 55)
            popUpView.layer.bounds.size.height = 600
            popUpView.layer.bounds.size.width = 450
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, viewInScroll.layer.bounds.height - 370, 0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //Adds working return button
        self.view.endEditing(true)
        return false
    }
    
    @objc func doneClicked() { //Adds done button to keyboard
        self.view.endEditing(true)
    }
    
    func openPopUp() { //Opens help menu
        self.view.addSubview(popUpView)
        popUpView.center = self.view.center
        
        popUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popUpView.alpha = 0
        
        self.visualEffectView.layer.bounds.size.width = self.view.layer.bounds.width
        self.visualEffectView.layer.bounds.size.height = self.view.layer.bounds.height
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }
    }
    
    func closePopUp() { //Closes help menu
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popUpView.alpha = 0
            
            self.visualEffectView.effect = nil
        }, completion: { (success:Bool) in
            self.popUpView.removeFromSuperview()
        })
        
        self.visualEffectView.layer.bounds.size.height = 0
        self.visualEffectView.layer.bounds.size.width = 0
    }
    
    func initialLaunch() { //Checks if is initial launch
        let defaults = UserDefaults.standard
        
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isFirstLaunch"){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
        }else{
            defaults.set(true, forKey: "isFirstLaunch")
            print("App launched first time")
            self.openPopUp()
        }
    }

}

enum UIUserInterfaceIdiom: Int { //Checks device type
    case unspecified
    
    case phone // iPhone and iPod touch style UI
    case pad // iPad style UI
}

