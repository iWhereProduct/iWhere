//
//  CoordsVC.swift
//  IWHERE
//
//  Created by Михаил on 30.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse
import MapKit

class CoordsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate  {
    
    //_Variabels and const_________________________________________________________________________________________ ->
    let serverOperations = ServerOperations(className: "coordRequest")
    var movedRight: Bool = false
    let moveDistance = 210
    var userInfo: PFObject?{
        didSet{
            getCoordRequestList()
        }
    }
    var requests: [PFObject]? {
        didSet{
            getArrayOfCoordFromRequestArray()
        }
    }
    var arrayOfCoords: [CLLocationCoordinate2D]?{
        didSet{
            setUpMap()
        }
    }
   
    //_____________________________________________________________________________________________________________ <-
    
    //_Outlets_____________________________________________________________________________________________________ ->
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var askWithPhoto: UIButton!
    @IBOutlet weak var askCoords: UIButton!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var map: MKMapView!
    //_____________________________________________________________________________________________________________ <-
    
    //_Initialization_______________________________________________________________________________________________ ->
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        map.delegate = self
        
    }
    //_____________________________________________________________________________________________________________ <-
    
    //_Table View___________________________________________________________________________________________________ ->
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requests != nil {
            return requests!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coords") as! CoordsCell
        if requests != nil {
            cell.adressLabel.text = requests![indexPath.row]["address"] as? String
            cell.timeLabel.text = requests![indexPath.row].createdAt!.convertDate()
            cell.rowLabel.text = String(indexPath.row)
            
        }
        return cell
    }
    //_____________________________________________________________________________________________________________ <-
    
    //_UI Actions__________________________________________________________________________________________________ ->
    @IBAction func moreButtonAction(_ sender: UIButton) {
        if movedRight {
            moveView(view: moreView, moveDistance: moveDistance, right: false)
            moveView(view: moreButton, moveDistance: moveDistance, right: false)
            movedRight = false
        }
        else {
            moveView(view: moreView, moveDistance: moveDistance, right: true)
            moveView(view: moreButton, moveDistance: moveDistance, right: true)
            movedRight = true
        }
    }
    
    @IBAction func askWithPhotoAction(_ sender: UIButton) {
        createRequest(withPhoto: true)
    }
    
    @IBAction func AskCoordsAction(_ sender: UIButton) {
        createRequest(withPhoto: false)
    }
    //_____________________________________________________________________________________________________________ <-
    
    //_Other func__________________________________________________________________________________________________ ->
    func setUpMap(){
        if arrayOfCoords != nil {
            var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            var maxLat: CLLocationDegrees = 0
            var maxLong: CLLocationDegrees = 0
            for coord in arrayOfCoords!{
                location = CLLocationCoordinate2D(latitude: location.latitude + coord.latitude, longitude: location.longitude + coord.longitude)
                if maxLat < coord.latitude{
                    maxLat = coord.latitude
                }
                if maxLong < coord.longitude {
                    maxLong = coord.longitude
                }
            }
            location = CLLocationCoordinate2D(latitude: location.latitude / CLLocationDegrees(arrayOfCoords!.count), longitude: location.longitude / CLLocationDegrees(arrayOfCoords!.count))
            let span = MKCoordinateSpan(latitudeDelta: maxLat - location.latitude, longitudeDelta: maxLong - location.longitude)
            let region = MKCoordinateRegion(center: location, span: span)
            map.setRegion(region, animated: true)
            
        }
    }
    func createRequest(withPhoto: Bool){
        if userInfo != nil {
            let request = PFObject(className: "coordRequest")
            request["id"] = PFUser.current()!
            request["friendId"] = userInfo!.objectId!
            request["deleted"] = false
            request["friendDeleted"] = true
            request["withPhoto"] = withPhoto
            serverOperations.saveToServer(object: request)
        }
    }
    
    func sutUp() {
        infoView.layer.masksToBounds = true
        infoView.layer.cornerRadius = 20
        infoView.layer.borderColor = UIColor.mainGray.cgColor
        infoView.layer.borderWidth = 3.0
    }
    
    func moveView(view: UIView, moveDistance: Int, right: Bool){
        let moveDuration = 0.4
        let movement = CGFloat(right ? moveDistance : -moveDistance)
        
        UIView.animate(withDuration: moveDuration, delay: 0, options: .curveEaseIn, animations: {
            view.layer.frame = view.layer.frame.offsetBy(dx: movement, dy: 0)
        }, completion: nil)
    }
    
    func getCoordRequestList(){
        if let user = userInfo {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let request = self?.serverOperations.getListOfCoordRequests(friendId: user.objectId!, deniedInclude: false)
                DispatchQueue.main.async {
                    self?.requests = request
                    self?.table.reloadData()
                }
            }
        }
    }
    
    func getArrayOfCoordFromRequestArray (){
        if requests != nil {
            var locationArray = [CLLocationCoordinate2D]()
            for request in requests!{
                if let coords = (request["Location"] as? String)?.covertStringCoordsToCLLoacationCordinate2D() {
                    locationArray.append(coords)
                }
            }
            arrayOfCoords = locationArray
        }
    }
    
    //_____________________________________________________________________________________________________________ <-
}
