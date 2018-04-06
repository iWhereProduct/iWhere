//
//  FriensVC.swift
//  IWHERE
//
//  Created by Михаил on 04.12.2017.
//  Copyright © 2017 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class FriendVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var requestsButton: UIButton!
    @IBOutlet weak var bageImage: UIImageView!
    
    private var numberOfRowForSegue: Int?
    private let serverOperations = ServerOperations()
    private var cellWillDelete = false
    
    private var userInfo: [PFObject]?{
        didSet{
            filteredUserInfo = userInfo
        }
    }
    
    private var filteredUserInfo: [PFObject]?{
        didSet{
            if !cellWillDelete {
                table.reloadData()
            }
        }
    }
    
    //_table View________________________________________________________________________________________________________________ ->
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredUserInfo != nil {
            return filteredUserInfo!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellFriends", for: indexPath) as! FriendsTableCell
        if let usersInfo = filteredUserInfo {
            cell.user = usersInfo[indexPath.row]
            cell.table = self
            cell.friendName.text = usersInfo[indexPath.row]["name"] as? String
            cell.friendUsername.text = usersInfo[indexPath.row]["username"] as? String
            if let photoFile = usersInfo[indexPath.row]["photo"] as? PFFile{
                cell.photoFile = photoFile
            }
            cell.friendImage.layer.masksToBounds = true
            cell.friendImage.layer.borderWidth = 3.0
            cell.friendImage.layer.borderColor = UIColor.mainGray.cgColor
            cell.friendImage.layer.cornerRadius = cell.friendImage.bounds.size.width / 2
            cell.indicator.stopAnimating()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let request = requestAction(at: indexPath)
        let requsetWithCam = requestActionWithCam(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [requsetWithCam, request])
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        numberOfRowForSegue = indexPath.row
        performSegue(withIdentifier: "friendProfile", sender: nil)
        return nil
    }
    //___________________________________________________________________________________________________________________________ <-
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        table.rowHeight = 70
        requestsButton.setImage(UIImage(named:"friendsImg")?.withRenderingMode(.alwaysTemplate), for: .normal)
        requestsButton.tintColor = UIColor.mainGray
        let tabBar = tabBarController as! TabBarController
        tabBar.friendVC = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.serverOperations.checkFriends(handler: nil)
        }
        getNameAndUsername()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendProfile", numberOfRowForSegue != nil {
            let vc = segue.destination as! FriendProfileVC
            vc.friendObject = filteredUserInfo?[numberOfRowForSegue!]
        }
    }
    @IBAction func requestsButtonAction(_ sender: UIButton) {
        tabBarItem.badgeValue = nil
        bageImage.isHidden = true
    }
    
    
    //_actions_for_swipe__________________________________________________________________________________________________________ ->
    private func requestAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "request") { [weak self] (action, view, complete) in
            self?.makeCoordRequest(at: indexPath)
            complete(true)
        }
        action.backgroundColor = UIColor.gray
        action.image = #imageLiteral(resourceName: "locationImg")
        return action
    }
    
    private func requestActionWithCam(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "requestWC") { (action, view, complete) in
            complete(true)
        }
        action.image = #imageLiteral(resourceName: "cameraImg")
        return action
    }
    
    private func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, complete) in
            complete(true)
            self.deleteAlert(at: indexPath)
        }
        action.backgroundColor = .red
        return action
    }
    //___________________________________________________________________________________________________________________________ <-
    
    //_search_Bar________________________________________________________________________________________________________________ ->
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty == false {
            tapRecognizer.isEnabled = true
            filteredUserInfo = filteredUserInfoArray(searchText: searchText)
        }
        else {
            filteredUserInfo = userInfo
        }
    }
    
    private func filteredUserInfoArray(searchText: String) -> [PFObject]? {
        if userInfo != nil {
            return userInfo!.filter({ (object) -> Bool in
                return (object["name"] as! String).lowercased().contains(searchText.lowercased())
            })
        }
        return nil
    }
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func tapRecognizer(_ sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
        tapRecognizer.isEnabled = false
    }
    
    //___________________________________________________________________________________________________________________________ <-
    
    //_other_func________________________________________________________________________________________________________________ ->
    private func deleteAlert(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "DELETE FRIEND", message: "Do you want to delete friend?", preferredStyle: UIAlertControllerStyle.alert)
        let deleteAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.destructive) { [weak self](action) in
            if self?.filteredUserInfo != nil {
                var idArray: Array<String>? = PFUser.current()!["friends"] as? [String]
                idArray = idArray?.filter{
                    $0 != self?.filteredUserInfo![indexPath.row].objectId!
                }
                PFUser.current()!["friends"] = idArray
                self?.serverOperations.saveToServer(object: PFUser.current()!)
                self?.cellWillDelete = true
                self?.filteredUserInfo!.remove(at: indexPath.row)
                self?.table.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                self?.cellWillDelete = false
            }
            alert.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func makeCoordRequest(at indexPath: IndexPath){
        if filteredUserInfo != nil {
            let coordRequest = PFObject(className: "coordRequest")
            coordRequest["id"] = PFUser.current()!
            coordRequest["friendId"] = filteredUserInfo![indexPath.row].objectId!
            coordRequest["deleted"] = false
            coordRequest["withPhoto"] = false
            serverOperations.saveToServer(object: coordRequest)
        }
    }
    
    private func getNameAndUsername () {
        DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
            var userInfo: [PFObject] = []
            if let listOfFriends = PFUser.current()?["friends"] as? [String] {
                   for friend in listOfFriends{
                    if let user = self?.serverOperations.getUserData(id: friend){
                        userInfo.append(user)
                    }
                }
                DispatchQueue.main.async {
                    if userInfo.count > 1 {
                        userInfo.sort{($0["name"] as! String) < ($1["name"] as! String)}
                    }
                    self?.userInfo = userInfo
                }
            }
        }
    }
    
    func setUpBadge(string: String?) {
        bageImage.layer.masksToBounds = true
        var image = UIImage()
        if string != nil {
            image = (UIImage(named: "redCircleImg")?.withRenderingMode(.alwaysTemplate).addStringAtCenterOfCurrentImage(string: NSString(string: string!), colorOfString: UIColor.white))!
        }
        else {
            image = (UIImage(named: "redCircleImg")?.withRenderingMode(.alwaysTemplate))!
            }
        bageImage.image = image
        bageImage.tintColor = UIColor.red
    }
    
    //___________________________________________________________________________________________________________________________ <-
    
}

