//
//  AddFriendVC.swift
//  IWHERE
//
//  Created by Михаил on 26.01.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class AddFriendVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate{
    
    let operationServer = ServerOperations(className: "friendsRequest")
    var users: Array<PFObject>?{
        didSet{
            tableView.reloadData()
        }
    }
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.autocapitalizationType = UITextAutocapitalizationType.none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users != nil{
            return users!.count
        }
        return 0
    }
    
    func getUsernameArrayFromUser(users: Array<PFObject>) -> Array<String>{
        var username = [String]()
        for user in users {
            username.append(user["username"] as! String)
        }
        return username
    }
    func getNameArrayFromUser(users: Array<PFObject>) -> Array<String>{
        var name = [String]()
        for user in users {
            name.append(user["name"] as! String)
        }
        return name
    }
    func getIdArrayFromUsers(users: Array<PFObject>) -> Array<String>{
        var name = [String]()
        for user in users {
            name.append(user.objectId!)
        }
        return name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath)
        if users != nil {
            cell.textLabel?.text = getNameArrayFromUser(users: users!)[indexPath.row]
            cell.detailTextLabel?.text = getUsernameArrayFromUser(users: users!)[indexPath.row]
        }
        else {
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friendRequest = PFObject(className: "friendsRequest")
        friendRequest["id"] = PFUser.current()!
        friendRequest["friendId"] = getIdArrayFromUsers(users: users!)[indexPath.row]
        operationServer.saveToServer(object: friendRequest)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapRegognizer(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != ""{
            if searchBar.text!.count >= 4 {
                let text = searchBar.text!
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let user = self?.operationServer.getUserList(username: text)
                    DispatchQueue.main.async {
                        self?.users = user
                    }
                }
            }
            else {
                users = nil
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
