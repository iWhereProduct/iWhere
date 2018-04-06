//
//  HistoryVC.swift
//  IWHERE
//
//  Created by Михаил on 04.12.2017.
//  Copyright © 2017 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //_Variabels and const_________________________________________________________________________________________ ->
    var numberOfRowForSegue: Int?
    var listOfCoordRequest: [PFObject]? = nil
    var userListWithInfo:[PFObject] = []
    var serverOperations: ServerOperations? = ServerOperations(className: "coordRequest")
    //_____________________________________________________________________________________________________________ <-

    
    //_outlets_____________________________________________________________________________________________________ ->
    @IBOutlet weak var inOrOut: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    //_____________________________________________________________________________________________________________ <-
    
    
    //_initialzation and apears____________________________________________________________________________________ ->
    override func viewDidLoad() {
        table.rowHeight = 80
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        inOrOut.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "inOrOut")
        if inOrOut.selectedSegmentIndex == 0 {
            getListOfCoordRequest(In: true)
        }
        else {
            getListOfCoordRequest(In: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.set(inOrOut.selectedSegmentIndex, forKey: "inOrOut")
    }
    //_____________________________________________________________________________________________________________ <-
    
    
    //_table View__________________________________________________________________________________________________ ->
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listOfCoordRequest != nil {
            return listOfCoordRequest!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch inOrOut.selectedSegmentIndex {
        case 0:
            if listOfCoordRequest != nil, userListWithInfo != [] { // Case "In"
                let cell = tableView.dequeueReusableCell(withIdentifier: "inCell", for: indexPath) as! HistoryInCell
                let date = listOfCoordRequest![indexPath.row].createdAt!
                cell.parentClass = self
                cell.showAll()
                cell.requestObject = listOfCoordRequest![indexPath.row]
                cell.timeLabel.text = date.convertDate()
                cell.nameLabel.text = userListWithInfo[indexPath.row]["name"] as? String
                cell.usernameLabel.text = userListWithInfo[indexPath.row]["username"] as? String
                
                if listOfCoordRequest![indexPath.row]["Accepted"] != nil{
                    if listOfCoordRequest![indexPath.row]["Accepted"] as! Bool == true {
                        cell.turnOffButton(accepted: true)
                    }
                    if listOfCoordRequest![indexPath.row]["Accepted"] as! Bool == false {
                        cell.turnOffButton(accepted: false)
                    }
                }
                if listOfCoordRequest![indexPath.row]["withPhoto"] as! Bool {
                    let newSize = CGSize(width: cell.imageOfType.frame.size.width / 1.5 , height: cell.imageOfType.frame.size.height / 1.5)
                    let image = UIImage(named: "cameraImg")?.resizeCurrentImage(size:newSize)!.withRenderingMode(.alwaysTemplate)
                    
                    cell.imageOfType.image = image
                    cell.imageOfType.tintColor = UIColor.mainGray
                }
                else {
                    let newSize = CGSize(width: cell.imageOfType.frame.size.width / 1.5 , height: cell.imageOfType.frame.size.height / 1.5)
                    let image = UIImage(named: "locationImg")?.resizeCurrentImage(size:newSize)?.withRenderingMode(.alwaysTemplate)
                    
                    cell.imageOfType.image = image
                    cell.imageOfType.tintColor = UIColor.mainGray
                }
                return cell
            }
            
        case 1:
            if listOfCoordRequest != nil, userListWithInfo != [] {
                let cell = tableView.dequeueReusableCell(withIdentifier: "outCell", for: indexPath) as! HistoryOutCell // Case "Out"
                cell.setUp()
                cell.parentClass = self
                let date = listOfCoordRequest![indexPath.row].createdAt!
                cell.timeLabel.text = date.convertDate()
                cell.nameLabel.text = userListWithInfo[indexPath.row]["name"] as? String
                cell.userNaameLabel.text = userListWithInfo[indexPath.row]["username"] as? String
                if let result = listOfCoordRequest![indexPath.row]["Accepted"] as? Bool{
                    if result {
                        if listOfCoordRequest![indexPath.row]["withPhoto"] as! Bool {
                            cell.setTypeOfButton(type: .readAndWithPhoto)
                        }
                        else {
                            cell.setTypeOfButton(type: .readAndWithoutPhoto)
                        }
                    }
                    else {
                        cell.setTypeOfButton(type: .denied)
                    }
                }
                else {
                    cell.setTypeOfButton(type: .unread)
                }
                return cell
                }
        default: return UITableViewCell()
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, listOfCoordRequest != nil {
            let newCoordRequest = listOfCoordRequest![indexPath.row]
            if inOrOut.selectedSegmentIndex == 0{
                newCoordRequest["friendDeleted"] = true
            }
            else {
                newCoordRequest["deleted"] = true
            }
            DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
                self?.serverOperations?.deleteIfNeeded(objectThatDeleted: newCoordRequest){ (result) in
                    if !result {
                        self?.serverOperations?.saveToServer(object: newCoordRequest)
                    }
                }
                DispatchQueue.main.async {
                    self?.listOfCoordRequest!.remove(at: indexPath.row)
                    self?.userListWithInfo.remove(at: indexPath.row)
                    self?.table.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    //_____________________________________________________________________________________________________________ <-
    
    
    //_UI Actions__________________________________________________________________________________________________ ->
    @IBAction func inOrOut(_ sender: UISegmentedControl) {
        serverOperations = nil
        serverOperations = ServerOperations(className: "coordRequest")
        if inOrOut.selectedSegmentIndex == 0 {
            getListOfCoordRequest(In: true)
            table.rowHeight = 80
        }
        else {
            getListOfCoordRequest(In: false)
            table.rowHeight = 70
        }
    }
    //_____________________________________________________________________________________________________________ <-
    
    //_Segue_________________________________________________________________________________________________ ->

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if numberOfRowForSegue != nil {
            if let coordRequest = listOfCoordRequest?[numberOfRowForSegue!] {
                let viewController = segue.destination as! MapAndPhotoVC
                viewController.coordRequest = coordRequest
            }
        }
    }
    //_____________________________________________________________________________________________________________ <-
    
    //_Other Functions_____________________________________________________________________________________________ ->
    func getListOfCoordRequest(In: Bool){
        DispatchQueue.global(qos:.userInitiated).async{ [weak self] in
            var listOfCoordRequest:[PFObject]?
            var userListWithInfo:[PFObject] = []
            if In {
                listOfCoordRequest = self?.serverOperations!.getFromServer(keyWord: "friendId", equalTo: PFUser.current()!.objectId!, me: false)
                for coordRequest in listOfCoordRequest!{
                    userListWithInfo.append(self!.serverOperations!.getUserData(id: (coordRequest["id"] as! PFObject).objectId!)!)
                }
            }
            else{
                listOfCoordRequest = self?.serverOperations!.getFromServer(keyWord: "id", equalTo: PFUser.current()!, me: true)
                for coordRequest in listOfCoordRequest!{
                    userListWithInfo.append(self!.serverOperations!.getUserData(id: coordRequest["friendId"] as! String)!)
                }
            }
            DispatchQueue.main.async {
                self?.listOfCoordRequest = listOfCoordRequest
                self?.userListWithInfo = userListWithInfo
                self?.table.reloadData()
            }
        }
    }
    //_____________________________________________________________________________________________________________ <-
    
}


