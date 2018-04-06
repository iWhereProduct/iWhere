//
//  FriendProfileVC.swift
//  IWHERE
//
//  Created by Михаил on 12.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class FriendProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
// Variables ------------------------------------------------------>
    private let serverOperations = ServerOperations(className: "coordRequest")
    public var friendObject: PFObject?
    private var updateTable: Bool = false
    public var rowForSegue: Int?
    private var listOfRequests: [PFObject]? {
        didSet{
            if updateTable{
                tableView.reloadData()
                updateTable = false
            }
        }
    }
// ---------------------------------------------------------------->
    
// Outlets -------------------------------------------------------->
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var friendPhotoImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendUsernameLabel: UILabel!
    @IBOutlet weak var askCoordsWithPhotoButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var askCoordButton: UIButton!
    
// ---------------------------------------------------------------->
    
// Initialization ------------------------------------------------->
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if friendObject != nil {
            friendNameLabel.text = friendObject!["name"] as? String
            friendUsernameLabel.text = friendObject!["username"] as? String
        }
        setUp()
        getListOfRequests()
        getPhotoFormServer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "map", rowForSegue != nil{
            let vc = segue.destination as! MapAndPhotoVC
            if let coordRequest = listOfRequests?[rowForSegue!]{
                vc.coordRequest = coordRequest
            }
        }
    }
// ---------------------------------------------------------------->
    
// TableView functions -------------------------------------------->
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listOfRequests != nil {
            return listOfRequests!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! FriendProfileCell
        cell.parentClass = self
        if listOfRequests != nil {
            if listOfRequests![indexPath.row].createdAt == nil {
                cell.timeLabel.text = Date().getCurrentDate()
            }
            else {
                cell.timeLabel.text = listOfRequests![indexPath.row].createdAt!.convertDate()
            }
            if (listOfRequests![indexPath.row]["id"] as! PFUser).objectId! == PFUser.current()!.objectId!{
                cell.inBox_OutBoxLabel.text = "OutBox"
                if listOfRequests![indexPath.row]["Accepted"] as? Bool != nil{
                    if (listOfRequests![indexPath.row]["Accepted"] as! Bool) == false {
                        cell.photoButton.isEnabled = false
                        cell.photoButton.setTitle("Denied", for: .disabled)
                        cell.photoButton.setTitleColor(UIColor.red, for: .disabled)
                        cell.photoButton.layer.borderWidth = 0
                    }
                    else {
                        if (listOfRequests![indexPath.row]["withPhoto"] as! Bool) == true {
                            cell.photoButton.isEnabled = true
                            cell.photoButton.setTitle("Photo", for: .normal)
                        }
                        else {
                            cell.photoButton.isEnabled = true
                            cell.photoButton.setTitle("Coords", for: .normal)
                        }
                    }
                }
                else {
                    cell.inBox_OutBoxLabel.text = "Unread"
                }
            }
            else {
                cell.inBox_OutBoxLabel.text = "InBox"
            }
        }
        return cell
    }
// ---------------------------------------------------------------->
    
// Button Actions ------------------------------------------------->
    @IBAction func askCoordWithPhotoButtonAction(_ sender: UIButton) {
        basicRequest(withPhoto: true){ [weak self] in
            self?.successAlert(message: "Request with photo successfully sended")
        }
    }
    
    @IBAction func askCoordButtonAction(_ sender: UIButton) {
        basicRequest(withPhoto: false){ [weak self] in
            self?.successAlert(message: "Request successfully sended")
        }
    }

    @IBAction func dismissButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
// ---------------------------------------------------------------->
    
// Getting data from server --------------------------------------->
    private func getListOfRequests() {
        var requestList = [PFObject]()
        if friendObject != nil {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let inBoxList = self?.serverOperations.getListOfCoordRequests(friendId: self!.friendObject!.objectId!, deniedInclude: true)
                let query = PFQuery(className: "coordRequest")
                query.whereKey("id", equalTo: self!.friendObject!)
                query.whereKey("friendId", equalTo: PFUser.current()!.objectId!)
                do {
                    let outBoxList = try? query.findObjects()
                    if outBoxList != nil{
                        requestList = outBoxList!
                    }
                }
                if inBoxList != nil {
                    requestList.append(contentsOf: inBoxList!)
                    requestList.sort{
                        return $0.createdAt! < $1.createdAt!
                    }
                }
                DispatchQueue.main.async {
                    self?.updateTable = true
                    self?.listOfRequests = requestList
                }
            }
        }
    }
    
    private func getPhotoFormServer(){
        if friendObject != nil {
            if let file = friendObject!["photo"] as? PFFile{
                DispatchQueue.global(qos:.userInitiated).async { [weak self] in
                    if let data = self?.serverOperations.getDataFromPFFile(PFFile: file){
                        if let image = UIImage(data: data){
                            DispatchQueue.main.async {
                                self?.friendPhotoImageView.image = image
                            }
                        }
                    }
                }
            }
        }
    }
// ---------------------------------------------------------------->
    
// Other functions ------------------------------------------------>
    private func setUp(){
        dismissButton.setTitleColor(UIColor.mainGray, for: .normal)
        
        let standartImage = UIImage(named: "profileImg")?.withRenderingMode(.alwaysTemplate)
        friendPhotoImageView.image = standartImage
        friendPhotoImageView.tintColor = UIColor.mainGray
        
        friendPhotoImageView.layer.cornerRadius = friendPhotoImageView.bounds.size.width / 2
        friendPhotoImageView.layer.borderColor = UIColor.mainGray.cgColor
        friendPhotoImageView.layer.borderWidth = 3.0
        friendPhotoImageView.layer.masksToBounds = true
        
        friendUsernameLabel.textColor = UIColor.mainGray
        
        askCoordsWithPhotoButton.layer.cornerRadius = 20
        askCoordsWithPhotoButton.backgroundColor = UIColor.secondaryGray
        askCoordsWithPhotoButton.layer.borderColor = UIColor.mainGray.cgColor
        askCoordsWithPhotoButton.layer.borderWidth = 2.0
        askCoordsWithPhotoButton.layer.masksToBounds = true
        
        askCoordButton.layer.cornerRadius = 20
        askCoordButton.backgroundColor = UIColor.secondaryGray
        askCoordButton.layer.borderColor = UIColor.mainGray.cgColor
        askCoordButton.layer.borderWidth = 2.0
        askCoordButton.layer.masksToBounds = true
        
    }
    
    private func basicRequest(withPhoto: Bool, completionHandler: (() -> Void)? ){
        let requestObject = PFObject(className: "coordRequest")
        requestObject["id"] = PFUser.current()!
        requestObject["deleted"] = false
        requestObject["friendDeleted"] = false
        requestObject["friendId"] = friendObject?.objectId! ?? ""
        if withPhoto {
            requestObject["withPhoto"] = true
        }
        else{
            requestObject["withPhoto"] = false
        }
        serverOperations.saveToServer(object: requestObject)
        listOfRequests?.insert(requestObject, at: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0 ,section: 0)], with: .automatic)
        tableView.endUpdates()
        completionHandler?()
    }
    
    private func successAlert(message: String){
        let alertController = UIAlertController(title: "Request send", message: message, preferredStyle: .alert)
        let OkAlertAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OkAlertAction)
        self.present(alertController, animated: true, completion: nil)
    }
// ---------------------------------------------------------------->
}

