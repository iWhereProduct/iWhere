//
//  FriendsTableCellVC.swift
//  IWHERE
//
//  Created by Михаил on 16.12.2017.
//  Copyright © 2017 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class FriendsTableCell: UITableViewCell {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendUsername: UILabel!
    var user: PFObject?
    var table: UIViewController?
    var photoFile: PFFile? {
        didSet{
            if photoFile != nil {
                getPhotoFromServer(file: photoFile!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let standartImage = UIImage(named: "profileImg")?.withRenderingMode(.alwaysTemplate)
        friendImage.image = standartImage
        friendImage.tintColor = UIColor.mainGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    @IBAction func buttonMapAction(_ sender: UIButton) {
    }
    func getPhotoFromServer(file: PFFile) {
        file.getDataInBackground { (data, error) in
            if error == nil, data != nil {
                if let image = UIImage(data: data!){
                    DispatchQueue.main.async { [weak self] in
                        self?.friendImage.image = image
                    }
                }
            }
        }
    }
}
