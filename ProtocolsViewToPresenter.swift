//
//  Protocols.swift
//  IWHERE
//
//  Created by Михаил on 31.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import Foundation
import UIKit

// LogIn Page

protocol ViewToPresenterLogInPageProtocol: class{
    func resetPassword(presenterView: UIViewController)
    func checkUsernameAndPasswordTextfield(username: String?, password: String?)
    weak var toView: PresenterToViewLogInPageProtocol? {get set}
    func clearLabels()
}

// CreateAccount Page

protocol ViewToPresenterCreateAccountPageProtocol: class {
    func choosePhotoActionAlert (operatorVC: UIViewController)
    func createUser (operatorVC: UIViewController, name: String?, username: String?, password: String?, email: String?, confirmPassword: String?)
    func getImage(image: UIImage?)
    func keyBoardHeightChanged(view: UIView, notification: Notification)
    weak var toView: PresenterToViewCreateAccountProtocol? {get set}
}
