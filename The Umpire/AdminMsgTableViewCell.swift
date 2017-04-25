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
    @IBOutlet var msgLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
