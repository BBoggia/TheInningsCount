//
//  CustomTypes.swift
//  The Umpire
//
//  Created by Branson Boggia on 3/14/18.
//  Copyright © 2018 PineTree Studios. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

let charSet = CharacterSet(charactersIn: "$/\\#[].")

struct leagueInfo {
    var leagueName: String!
    var leagueNumber: String!
    var division: String!
    var team: String!
    var isAdmin: Bool!
}

struct UsrAcc {
    var user: User!
    var uid, email, firstName, lastName: String!
    var leagues = [leagueInfo()]
}

var userAcc = UsrAcc()

struct Refs {
    let ref = Database.database().reference()
    let usrRef = Database.database().reference().child("UserData")
    let statRef = Database.database().reference().child("LeagueStats")
    let dataRef = Database.database().reference().child("LeagueData")
}

struct Coach {
    var name, uid, email, div, team: String!
    var isAdmin, isOwner: Bool!
}

struct JoinRequest {
    var name, dateRequested, email, div, team, dateAccepted, uid: String!
    var requestStatus: Bool!
}

struct Stats {
    var player, inning, date, coach: String!
}

extension UIViewController {
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addGradientToView(view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blue, UIColor.red]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
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
