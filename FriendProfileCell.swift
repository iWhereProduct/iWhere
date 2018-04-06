//
//  FriendProfileCell.swift
//  IWHERE
//
//  Created by Михаил on 12.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class FriendProfileCell: UITableViewCell {
    let serverOperations = ServerOperations(className: "coordRequest")
    var parentClass: FriendProfileVC?
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var inBox_OutBoxLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoButton.layer.borderColor = UIColor.mainGray.cgColor
        photoButton.layer.borderWidth = 1.0
        photoButton.layer.cornerRadius = 10
        photoButton.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func photoButtonAction(_ sender: UIButton) {
        if let parent = parentClass {
            parent.rowForSegue = indexPath?.row
            parent.performSegue(withIdentifier: "map", sender: nil)
        }
    }
    
}
