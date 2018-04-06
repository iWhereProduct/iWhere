//
//  SetUpView.swift
//  IWHERE
//
//  Created by Михаил on 01.04.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import Foundation
import UIKit

class SetUpView: NSObject, SetUpViewProtocol {
    
    func setUpImageView(arrayOfImageViews: [UIImageView?]) {
        for imageView in arrayOfImageViews{
            imageView?.clipsToBounds = true
            imageView?.layer.cornerRadius = imageView!.frame.size.width / 2
            imageView?.layer.borderWidth = 3.0
            imageView?.layer.borderColor = (UIColor.mainGray).cgColor
        }
    }
    
    func setUpButtons(arrayOfButtons: [UIButton?]) {
        for button in arrayOfButtons{
            button?.layer.cornerRadius = 25
            button?.layer.borderColor = UIColor.mainGray.cgColor
            button?.layer.borderWidth = 3.0
        }
    }
    
    func setUpTextFields(arrayOfTextfields: [UITextField?]) {
        for textField in arrayOfTextfields{
            textField?.layer.masksToBounds = true
            textField?.layer.cornerRadius = 15
            textField?.layer.borderWidth = 1.0
            textField?.layer.borderColor = (UIColor.mainGray).cgColor
        }
    }
    
    func setUpReturnOfTextfields(listOfTextfields: [UITextField?]) {
        
        
    }
}
