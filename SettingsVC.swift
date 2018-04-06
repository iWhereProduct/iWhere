//
//  SettingsVC.swift
//  IWHERE
//
//  Created by Михаил on 24.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class SettingsVC: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        logOutButton.layer.masksToBounds = true
        logOutButton.layer.cornerRadius = 30
        logOutButton.layer.borderColor = UIColor.red.cgColor
        logOutButton.layer.borderWidth = 3.0
    }

    @IBAction func logOutButton(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "login")
        UserDefaults.standard.removeObject(forKey: "password")
        PFUser.logOut()
    }
}
