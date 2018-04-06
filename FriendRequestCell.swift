//
//  FriendRequestCell.swift
//  IWHERE
//
//  Created by Михаил on 09.02.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class FriendRequestCell: UITableViewCell{
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var imageBox: UIImageView!
    let serverOperations = ServerOperations(className: "friendsRequest")
    var requestObject:PFObject? = nil
    let table = FriendRequestTableVC()
    var friendList: [String]?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func acceptButton(_ sender: UIButton) {
        if requestObject != nil, friendList != nil {
            requestObject!["Accepted"] = true
            friendList!.append((requestObject!["id"] as! PFObject).objectId!)
            let user = PFUser.current()!
            user["friends"] = friendList!
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.serverOperations.saveToServer(object: user)
                DispatchQueue.main.async {
                    self?.serverOperations.saveToServer(object: self!.requestObject!)
                }
            }
            acceptButton.isEnabled = false
            acceptButton.setTitle("Added to friends", for: .disabled)
            acceptButton.setTitleColor(UIColor.gray, for: .disabled)
            acceptButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
            denyButton.isHidden = true
        }
        
        
    }
    
    @IBAction func denyButton(_ sender: UIButton) {
        if requestObject != nil {
            serverOperations.deleteAtServer(object: requestObject!)
            denyButton.isEnabled = false
            denyButton.setTitle("Denied", for: .disabled)
            denyButton.setTitleColor(UIColor.gray, for: .disabled)
            denyButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
            acceptButton.isHidden = true
        }
    }
    func reset() {
        acceptButton.isHidden = false
        denyButton.isHidden = false
        acceptButton.isEnabled = true
        denyButton.isEnabled = true
        acceptButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        denyButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
    }
}
