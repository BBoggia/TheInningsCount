//
//  AdminHubViewController.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/17/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit
import CoreGraphics
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AdminHubViewController: UIViewController {
    
    var user: User!
    var userUID: String!
    var leagueCode: String!
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBAction func coachManager(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "coachManager") as! CoachManagerTableViewController
        vc.leagueCode = leagueCode
        vc.user = user
        self.navigationController?.pushViewController(vc,animated: true)
    }
    @IBAction func viewLeagueCode(_ sender: Any) {
        anotherAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser
        userUID = Auth.auth().currentUser?.uid

        self.view.gradientOfView(withColors: UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.0), UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleLbl.font = UIFont(name: titleLbl.font.fontName, size: 32)
        }
        
        if defaults.bool(forKey: "showAdminHubPopup") == nil || defaults.bool(forKey: "showAdminHubPopup") == true {
            popupAlert(title: "Admin Hub", message: "Here you can send global messages, view your league code, manage your coaches, and add, remove, and rename divisions and teams in your league.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func anotherAlert() {
        let alert = UIAlertController(title: "League Code", message: "Your league code is: \(leagueCode!)", preferredStyle: .alert)
        let done = UIAlertAction(title: "Done", style: .default, handler: nil)
        let copy = UIAlertAction(title: "Copy", style: .default) { (action) in
            UIPasteboard.general.string = self.leagueCode
        }
        alert.addAction(done)
        alert.addAction(copy)
        self.present(alert, animated: true, completion: nil)
    }

    func popupAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let dontShow = UIAlertAction(title: "Don't Show Again", style: .destructive) { (action) in
            self.defaults.set(false, forKey: "showAdminHubPopup")
        }
        alert.addAction(done)
        alert.addAction(dontShow)
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    func gradientOfView(withColors: UIColor...) {
        
        var cgColors = [CGColor]()
        
        for color in withColors {
            cgColors.append(color.cgColor)
        }
        let grad = CAGradientLayer()
        grad.frame = self.bounds
        grad.colors = cgColors
        self.layer.insertSublayer(grad, at: 0)
    }
}
