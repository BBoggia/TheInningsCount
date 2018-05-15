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

struct UsrAcc {
    var user: User!
    var uid, email, leagueName, div, team, firstName, lastName: String!
    var leagueNames, leagueNumbers, teamNames: [String]!
    var adminList: [Bool]!
    var isAdmin: Bool!
}

var userAcc = UsrAcc()

struct Refs {
    let ref = Database.database().reference()
    let usrRef = Database.database().reference().child("UserData")
    let statRef = Database.database().reference().child("LeagueStats")
    let dataRef = Database.database().reference().child("LeagueData")
}

extension UIViewController {
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
