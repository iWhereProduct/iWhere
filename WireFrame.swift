//
//  WireFrame.swift
//  IWHERE
//
//  Created by Михаил on 31.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import Foundation
import  UIKit

class Wireframe{
    
    
    class func performSegue(from: UIViewController, toSegueIndentificator: String) {
        
        from.performSegue(withIdentifier: toSegueIndentificator, sender: nil)
    }
    
    class func dismiss (view: UIViewController){
        view.dismiss(animated: true, completion: nil)
    }
}
