//
//  PlayerStatsTableViewCell.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/25/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit

class PlayerStatsTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var statLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
