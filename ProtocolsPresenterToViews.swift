//
//  ProtocolsPresenterToViews.swift
//  IWHERE
//
//  Created by Михаил on 31.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import Foundation
import UIKit

// LogIn Page

protocol PresenterToViewLogInPageProtocol: class {
    var errorLabelText: String? {get set}
    var errorPasswordText: String? {get set}
    var segueIndentificator: String {get}
}

protocol PresenterToViewCreateAccountProtocol: class, UINavigationControllerDelegate ,UIImagePickerControllerDelegate {
    var errorText: String? {get set}
    var imageData: Data? {get set}
}

protocol SetUpViewProtocol: class {
    func setUpTextFields(arrayOfTextfields: [UITextField?])
    func setUpButtons(arrayOfButtons: [UIButton?])
    func setUpImageView(arrayOfImageViews: [UIImageView?])
}
