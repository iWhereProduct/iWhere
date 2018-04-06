//
//  CoordsCell.swift
//  IWHERE
//
//  Created by Михаил on 30.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit

class CoordsCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var rowLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
