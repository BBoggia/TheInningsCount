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

struct UsrAcc {
    var UID: String!
    var Email: String!
    var Div: String!
    var Team: String!
}

struct Refs {
    let ref = Database.database().reference()
    let usrRef = Database.database().reference().child("UserData")
    let statRef = Database.database().reference().child("LeagueStats")
    let dataRef = Database.database().reference().child("LeagueData")
}
