//
//  HistoryOutCell.swift
//  IWHERE
//
//  Created by Михаил on 19.02.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit

class HistoryOutCell: UITableViewCell {
    
    var parentClass: HistoryVC?
    
    enum types{
        case readAndWithPhoto
        case readAndWithoutPhoto
        case unread
        case denied
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNaameLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }

    
    @IBAction func statusButtonAction(_ sender: UIButton) {
        parentClass?.numberOfRowForSegue = indexPath?.row
        parentClass?.performSegue(withIdentifier: "map", sender: nil)
        
    }
    
    public func setUp() {
        statusButton.layer.masksToBounds = true
        statusButton.layer.cornerRadius = 20
        statusButton.layer.borderWidth = 3.0
        statusButton.layer.borderColor = UIColor.mainGray.cgColor
        statusButton.isEnabled = true
    }
    
    public func setTypeOfButton(type: types){
        switch type {
        case .readAndWithPhoto:
            statusButton.setTitle("Photo", for: .normal)
        case .readAndWithoutPhoto:
            statusButton.setTitle("Coords", for: .normal)
        case .unread:
            statusButton.setTitle("Unread", for: .disabled)
            statusButton.layer.borderWidth = 0
            statusButton.isEnabled = false
        case .denied:
            statusButton.setTitle("Denied", for: .disabled)
            statusButton.setTitleColor(UIColor.red, for: .disabled)
            statusButton.layer.borderWidth = 0
            statusButton.isEnabled = false
        }
    }
}
