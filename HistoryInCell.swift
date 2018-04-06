//
//  HistoryInCell.swift
//  IWHERE
//
//  Created by Михаил on 19.02.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class HistoryInCell: UITableViewCell, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let manager: CLLocationManager = CLLocationManager()
    let locationOperations = LocationOperations()
    let serverOperations = ServerOperations(className: "coordRequest")
    var requestObject: PFObject?
    var parentClass: HistoryVC?
    
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageOfType: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
        manager.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func shareCoordsButton(_ sender: UIButton) {
        changeBadgeNum()
        if let requestObjectForMe = requestObject, let location = locationOperations.getLocation(), let locationCLL = locationOperations.getCLLocation(), let parent = parentClass {
            turnOffButton(accepted: true)
            requestObjectForMe["Accepted"] = true
            requestObjectForMe["Location"] = location
            getAddressFormCoords(coords: locationCLL)
            serverOperations.saveToServer(object: requestObjectForMe)
            if requestObjectForMe["withPhoto"] as! Bool {
                let image = UIImagePickerController()
                image.delegate = self
                image.sourceType = .camera
                image.allowsEditing = false
                parent.present(image, animated: true, completion: nil)
            }
        }
        else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let lowerImage = chosenImage.jpeg(.medium), requestObject != nil{
                let file = PFFile(name: requestObject!["friendId"] as! String + ".jpg", data: lowerImage)
                requestObject!["photo"] = file
                serverOperations.saveToServer(object: requestObject!)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func denyButtonAction(_ sender: UIButton) {
    changeBadgeNum()
    if let requestObjectForMe = requestObject{
        turnOffButton(accepted: false)
        requestObjectForMe["Accepted"] = false
        serverOperations.saveToServer(object: requestObjectForMe)
        }
    }
    
    func setUp(){
        shareButton.layer.cornerRadius = 20
        denyButton.layer.cornerRadius = 20
        shareButton.layer.borderWidth = 3.0
        shareButton.layer.borderColor = UIColor.green.cgColor
        denyButton.layer.borderWidth = 3.0
        denyButton.layer.borderColor = UIColor.red.cgColor
        imageOfType.layer.masksToBounds = true
        imageOfType.layer.cornerRadius = imageOfType.frame.size.width / 2
        imageOfType.layer.borderWidth = 3.0
        imageOfType.layer.borderColor = UIColor.mainGray.cgColor
    }

    func turnOffButton(accepted: Bool){
        if accepted{
            denyButton.isHidden = true
            shareButton.setTitle("Accepted", for: .disabled)
            shareButton.setTitleColor(UIColor.mainGray, for: .disabled)
            shareButton.setTitleShadowColor(UIColor.white, for: .disabled)
            shareButton.isEnabled = false
            shareButton.layer.borderWidth = 0
        }
        else {
            shareButton.isHidden = true
            denyButton.setTitle("Denied", for: .disabled)
            denyButton.setTitleColor(UIColor.mainGray, for: .disabled)
            denyButton.setTitleShadowColor(UIColor.white, for: .disabled)
            denyButton.isEnabled = false
            denyButton.layer.borderWidth = 0
        }
    }
    
    func showAll(){
        shareButton.isEnabled = true
        shareButton.layer.borderWidth = 3.0
        denyButton.isHidden = false
        denyButton.isEnabled = true
        denyButton.layer.borderWidth = 3.0
        shareButton.isHidden = false
    }
    
    func changeBadgeNum() {
        if let previosNum = parentClass?.tabBarItem.badgeValue {
            if previosNum == "1" {
                parentClass?.tabBarItem.badgeValue = nil
            }
            else {
                parentClass?.tabBarItem.badgeValue = String(Int(previosNum)! - 1)
            }
        }
    }
    
    func getAddressFormCoords (coords: CLLocationCoordinate2D){
        let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placeMark, error) in
            if let requestObject = self?.requestObject{
                requestObject["address"] = placeMark?[0].name ?? "Couldn't get address"
                self?.serverOperations.saveToServer(object: requestObject)

            }
        }
    }
}
