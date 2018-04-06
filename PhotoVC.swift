//
//  PhotoVC.swift
//  IWHERE
//
//  Created by Михаил on 26.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class PhotoVC: UIViewController {
    private let serverOperations = ServerOperations()
    private var photo: UIImage? {
        didSet{
            statusIndicator.stopAnimating()
            image.image = photo
            image.isHidden = false
        }
    }
    public var request: PFObject?
    
    @IBOutlet weak var statusIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveImageButton: UIButton!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        getImageFromServer()
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveImageButtonAction(_ sender: UIButton) {
        if photo != nil {
            if let compressedData = UIImagePNGRepresentation(photo!){
                if let compressedPhoto = UIImage(data: compressedData){
                    UIImageWriteToSavedPhotosAlbum(compressedPhoto, nil, nil, nil)
                    let alertController = UIAlertController(title: "Photo saved", message: "Your photo is saved to library", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Ok", style: .default){ (alert) in
                        alertController.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func deleteImageButtonAction(_ sender: UIButton) {
        if photo != nil, request != nil {
            let alertController = UIAlertController(title: "Delete Photo", message: "Do you want to delete photo?", preferredStyle: .alert)
            let deleteAlertAction = UIAlertAction(title: "Delete", style: .destructive){ [weak self] (alert) in
                self?.request!["photo"] = NSNull()
                self?.request!["withPhoto"] = false
                self?.serverOperations.saveToServer(object: self!.request!)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deletePhotoButton"), object: nil)
                self?.dismiss(animated: true, completion: nil)
            }
            
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(cancelAlertAction)
            alertController.addAction(deleteAlertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func setUp() {
        saveImageButton.layer.masksToBounds = true
        deleteImageButton.layer.masksToBounds = true
        saveImageButton.layer.borderWidth = 3.0
        deleteImageButton.layer.borderWidth = 3.0
        saveImageButton.layer.borderColor = UIColor.mainGray.cgColor
        deleteImageButton.layer.borderColor = UIColor.red.cgColor
        saveImageButton.layer.cornerRadius = 20
        deleteImageButton.layer.cornerRadius = 20
        
        adressLabel.text = request?["address"] as? String
        timeLabel.text = request?.createdAt?.convertDate()
    }
    
    private func getImageFromServer(){
        if request != nil {
            if let file = request!["photo"] as? PFFile {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let data = self?.serverOperations.getDataFromPFFile(PFFile: file){
                        DispatchQueue.main.async {
                            self?.photo = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }
}
