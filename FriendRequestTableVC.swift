//
//  FriendRequestTableVC.swift
//  IWHERE
//
//  Created by Михаил on 09.02.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class FriendRequestTableVC: UITableViewController{
    let serverOperations = ServerOperations(className: "friendsRequest")
    var friendRequestObject: [PFObject]?{
        didSet{
            getUserData()
        }
    }
    var userData: [PFObject]?{
        didSet{
            getListOfFriends()
        }
    }
    var friendList: [String]?{
        didSet{
            table.reloadData()
        }
    }
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFriendRequest()
    }
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendRequestObject != nil {
            return friendRequestObject!.count
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestCellInd", for: indexPath) as! FriendRequestCell
        if let user = userData, friendList != nil{
            cell.reset()
            cell.friendList = friendList
            cell.requestObject = friendRequestObject?[indexPath.row]
            cell.friendNameLabel.text = user[indexPath.row]["name"] as? String ?? "error"
        }
        return cell
    }

    override func viewDidDisappear(_ animated: Bool) {
        friendRequestObject = nil
    }
    
    @IBAction func cancelActionButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    func getFriendRequest(){
        DispatchQueue.global(qos:.userInitiated).async { [weak self] in
            let friendRequestObject = self?.serverOperations.getFromServer(keyWord: "friendId", equalTo: PFUser.current()!.objectId!, me: nil)
            DispatchQueue.main.async {
                self?.friendRequestObject = friendRequestObject
            }
        }
    }
    
    func getUserData(){
        if friendRequestObject != nil{
            var userData = [PFObject]()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                for request in self!.friendRequestObject!{
                    if let user = self?.serverOperations.getUserData(id: (request["id"] as! PFObject).objectId!) {
                        userData.append(user)
                    }
                }
                DispatchQueue.main.async {
                    if !userData.isEmpty {
                        self?.userData = userData
                    }
                    else {
                        self?.getFriendRequest()
                    }
                }
            }
        }
    }
    func getListOfFriends() {
        var friends = [String]()
        DispatchQueue.global(qos:.userInitiated).async {[weak self] in
            if let friend = (self?.serverOperations.getUserData(id: PFUser.current()!.objectId!)?["friends"] as? [String]) {
                friends.append(contentsOf: friend)
                DispatchQueue.main.async {
                    self?.friendList = friends
                }
            }
        }
    }
    
}
