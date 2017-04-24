//
//  CustomStandardButton.swift
//  The Umpire
//
//  Created by Branson Boggia on 4/23/17.
//  Copyright © 2017 PineTree Studios. All rights reserved.
//

import UIKit

@IBDesignable class CustomStandardButton: UIButton {

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}
