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
    
    var effect: UIVisualEffect!
    var alertTextfield: String!
    
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var viewInScroll: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var popUpTitle: UILabel!
    @IBOutlet weak var helpDesc: UILabel!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var popUpMainDesc: UILabel!
    @IBOutlet weak var popUpMainTitle: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var createLeagueHelp: UIButton!
    @IBOutlet weak var coachSignupHelp: UIButton!
    @IBOutlet weak var submitStatsHelp: UIButton!
    @IBOutlet weak var viewStatsHelp: UIButton!
    @IBAction func popUpBtns(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        switch button.tag {
        case 0:
            createLeaguePopup()
            break
        case 1:
            coachSignupPopup()
            break
        case 2:
            submitStatsPopup()
            break
        case 3:
            viewStatsPopup()
            break
        default:
            break
        }
        toggleTitle()
        button.tintAdjustmentMode = .normal
        button.tintAdjustmentMode = .automatic
    }
    
    @IBAction func helpButton(_ sender: Any) { //Opens help button
        visualEffectView.isHidden = false
        openPopUp()
    }
    @IBAction func close(_ sender: UIButton) { //Closes help button
        if viewInScroll.isHidden == false {
            viewInScroll.isHidden = true
            toggleTitle()
        } else {
            closePopUp()
            visualEffectView.isHidden = true
        }
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
                    
                    userAcc.uid = user?.uid
                    userAcc.user = user
                    self.emailField.text = ""
                    self.passwordField.text = ""
                    self.performSegue(withIdentifier: "toMC", sender: nil)
                } else {
                    
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            })
        }
    }
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func forgotPassword(_ sender: Any) {
        displayPasswordReset()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userAcc.user = Auth.auth().currentUser
        userAcc.uid = Auth.auth().currentUser?.uid
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
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
        popUpMainDesc.text = "If the below options aren't able to help you feel free to email me at bboggia912@gmail.com!"
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            appTitle.font = UIFont(name: appTitle.font.fontName, size: 55)
            popUpView.layer.bounds.size.height = 600
            popUpView.layer.bounds.size.width = 450
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, viewInScroll.layer.bounds.height, 0)
            popUpMainTitle.font = UIFont.systemFont(ofSize: 30)
            popUpTitle.font = UIFont.systemFont(ofSize: 30)
            helpDesc.font = UIFont.systemFont(ofSize: 25)
            popUpMainDesc.font = UIFont.systemFont(ofSize: 25)
            createLeagueHelp.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            coachSignupHelp.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            submitStatsHelp.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            viewStatsHelp.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        }
        
        initialLaunch() //Checks if is initial launch
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createLeaguePopup() {
        popUpTitle.text = "Creating a league"
        helpDesc.text = "1. First select 'Create a League' from the login page and enter the requested info.\n\n2. Then add each your leagues' divisions. (ex. Boys9-10, Boys 11-12)\n\n3. Next go through and select each division from the list and enter the teams for each.\n\n4. Finally press confirm and save the 5 digit code given at the end, coaches will need it to join your league."
        helpDesc.sizeToFit()
        viewInScroll.isHidden = false
    }
    
    func coachSignupPopup() {
        popUpTitle.text = "Signing up as a coach"
        helpDesc.text = "1. First contact the league admin for the 5 digit code if you dont have it already.\n\n2. Next press 'Coach Signup', enter the requested info, and select 'Create Account'.\n\n3. Finally select the division and team you coach for and you're done!"
        helpDesc.sizeToFit()
        viewInScroll.isHidden = false
    }
    
    func submitStatsPopup() {
        popUpTitle.text = "Submitting Stats"
        helpDesc.text = "1. First login using your email and password you created before.\n\n2. Next select the 'Enter Innings' button.\n\n3. Then enter the players information and hit submit."
        helpDesc.sizeToFit()
        viewInScroll.isHidden = false
    }
    
    func viewStatsPopup() {
        popUpTitle.text = "Viewing Stats"
        helpDesc.text = "1. First login using your email and password you created before.\n\n2. Next select the 'View League Stats' button.\n\n3. Then finally select the division and team you would like to view the stats for and they will be right there."
        helpDesc.sizeToFit()
        viewInScroll.isHidden = false
    }
    
    func toggleTitle() {
        if popUpMainDesc.isHidden == false || popUpMainTitle.isHidden == false {
            popUpMainTitle.isHidden = true
            popUpMainDesc.isHidden = true
        } else {
            popUpMainTitle.isHidden = false
            popUpMainDesc.isHidden = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //Adds working return button
        self.view.endEditing(true)
        return true
    }
    
    @objc func doneClicked() { //Adds done button to keyboard
        self.view.endEditing(true)
    }
    
    func setupPopUp() { //Help menu constraints
        popUpView.layer.cornerRadius = 5
        scrollView.layer.cornerRadius = 5
        viewInScroll.layer.cornerRadius = 5
        closeButton.layer.cornerRadius = 5
        visualEffectView.layer.bounds.size.height = 0
        visualEffectView.layer.bounds.size.width = 0
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, viewInScroll.layer.bounds.height, 0)
    }
    
    func openPopUp() { //Opens help menu
        self.setupPopUp()
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
            self.viewInScroll.isHidden = true
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
    
    func displayPasswordReset() {
        let myAlert = UIAlertController(title: "Password Reset", message: "Please enter the email used to create your account.", preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addTextField()
        let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { action in
            Auth.auth().sendPasswordReset(withEmail: myAlert.textFields![0].text!) { (error) in
                if error != nil {
                    self.displayAlert(title: "Oops!", message: "We couldn't find the email you entered.")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        self.present(myAlert, animated: true, completion: nil)
    }
}

enum UIUserInterfaceIdiom: Int { //Checks device type
    case unspecified
    case phone // iPhone and iPod touch style UI
    case pad // iPad style UI
}

