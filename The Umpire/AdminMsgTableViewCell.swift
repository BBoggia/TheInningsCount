//
//  AdminMsgTableViewCell.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/24/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit

class AdminMsgTableViewCell: UITableViewCell {

    @IBOutlet var dateLbl: UILabel!
    @IBOutlet weak var homeDateLbl: UILabel!
    @IBOutlet weak var leagueLbl: UILabel!
    @IBOutlet weak var msgLbl: UITextView!
    @IBOutlet weak var homeMsgLbl: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
