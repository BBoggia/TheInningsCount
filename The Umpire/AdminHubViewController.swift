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
    
    let user = FIRAuth.auth()?.currentUser
    let userUID = FIRAuth.auth()?.currentUser?.uid
    
    @IBAction func sendMsg(_ sender: Any) {
        
    }
    @IBAction func renameAge(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "renameTeam") as! AdminTableViewController
        
        navigationController?.pushViewController(vc,animated: true)
    }
    @IBAction func renameTeam(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "renameAge") as! RenameTeam1TableViewController
        
        navigationController?.pushViewController(vc,animated: true)
    }
    @IBAction func addRemoveAgeTeam(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "adminTable") as! AdminTableViewController
        
        navigationController?.pushViewController(vc,animated: true)
    }
    @IBAction func removeCoach(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "adminTable") as! AdminTableViewController
        
        navigationController?.pushViewController(vc,animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.gradientOfView(withColors: UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.0), UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
