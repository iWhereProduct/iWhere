//
//  MapAndPhotoVC.swift
//  IWHERE
//
//  Created by Михаил on 20.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import MapKit
import Parse

class MapAndPhotoVC: UIViewController, MKMapViewDelegate{
    
    var coordRequest: PFObject?
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        setUp()
        setUpMap()
        NotificationCenter.default.addObserver(self, selector: #selector(hidePhotoButton), name: NSNotification.Name(rawValue: "deletePhotoButton"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if coordRequest!["withPhoto"] as! Bool {
            photoButton.isHidden = false
        }
        else {
            photoButton.isHidden = true
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setUp(){
        let image = UIImage(named: "pictureImg")?.withRenderingMode(.alwaysTemplate)
        photoButton.setImage(image, for: .normal)
        photoButton.tintColor = UIColor.mainGray
        photoButton.layer.cornerRadius = 20
        photoButton.layer.masksToBounds = true
        photoButton.layer.borderWidth = 3.0
        photoButton.layer.borderColor = UIColor.mainGray.cgColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PhotoVC
        vc.request = coordRequest
    }
    
    
    func setUpMap(){
        if let coord = (coordRequest?["Location"] as? String)?.covertStringCoordsToCLLoacationCordinate2D(){
            let region = MKCoordinateRegionMakeWithDistance(coord, 1500, 1500)
            map.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            annotation.title = coordRequest?.createdAt?.convertDate()
            annotation.subtitle = coordRequest?["address"] as? String
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            map.addAnnotation(annotationView.annotation!)
        }
        else {
            print("Cannot get mapRegion")
        }
    }
    
    @objc func hidePhotoButton() {
        photoButton.isHidden = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if annotationView != nil {
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView?.canShowCallout = true
        }
        annotationView?.image = UIImage(named: "circleImg")?.addStringAtCenterOfCurrentImage(string: "1", colorOfString: UIColor.mainGray)
        return annotationView
    }
}
