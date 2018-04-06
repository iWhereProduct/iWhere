//
//  PresenterCreateAccount.swift
//  IWHERE
//
//  Created by Михаил on 31.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import Foundation
import UIKit
import Parse

class PresenterCreateAccount: NSObject, ViewToPresenterCreateAccountPageProtocol{
    
    weak var toView: PresenterToViewCreateAccountProtocol?{
        didSet{
            picker.delegate = toView
        }
    }
    
    private var viewMoved = false
    private var keyBoardHeight: Int = 0
    private let picker = UIImagePickerController()
    
    
    /**
     Show alert to get photo with 3 options:
        - Library: get image from photo library
        - Photo: get image from photo camera
        - Cancel: dismiss alert without any action
     - Parameters:
        - operatorVC: ViewController that will show alert.
    */
    public func choosePhotoActionAlert (operatorVC: UIViewController){
        let actionController = UIAlertController(title: "Get photo", message: "Choose directory", preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "Photo library", style: .default) {[weak self] (action) in
            self?.picker.sourceType = .photoLibrary
            self?.picker.allowsEditing = true
            operatorVC.present(self!.picker, animated: true, completion: nil)
        }
        let photoAction = UIAlertAction(title: "Camera", style: .default) {[weak self] (action) in
            self?.picker.sourceType = .camera
            self?.picker.allowsEditing = true
            if let picker = self?.picker {
                operatorVC.present(picker, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(libraryAction)
        actionController.addAction(photoAction)
        actionController.addAction(cancelAction)
        operatorVC.present(actionController, animated: true, completion: nil)
    }
    /**
     Get image and change it resolution
     */
    
    public func getImage(image: UIImage?){
        toView?.imageData = image?.jpeg(.lowest)
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func moveView(view: UIView, moveDistance: Int, up: Bool){
        let moveDuration = 0.3
        let movement = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.animate(withDuration: moveDuration, delay: 0, options: .curveLinear, animations: {
            view.layer.bounds = view.layer.bounds.offsetBy(dx: 0, dy: movement)
        }, completion: nil)
    }
    /**
     Move view up on half of height of keyboard, when keyboard appears, and move down, when keyboard disappears.
     - Parameters:
        - view: View, that will be moved
        - notification: Notification, that calls when keyboard appears/disappears.
     */
    public func keyBoardHeightChanged(view: UIView, notification: Notification){
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide, viewMoved {
            moveView(view: view, moveDistance: Int(keyBoardHeight) , up: false)
            viewMoved = false
            keyBoardHeight = 0
        }
        else if !viewMoved {
            moveView(view: view, moveDistance: Int(keyboardViewEndFrame.height / 2) , up: true)
            keyBoardHeight = Int(keyboardViewEndFrame.height / 2)
            viewMoved = true
        }
    }
    /**
        Get 5 values, check them and create user, depend on thous values (username, name, password, email)
     - Parameters:
        - operatorVC: ViewController, that will dismiss after user created.
     */
    public func createUser (operatorVC: UIViewController, name: String?, username: String?, password: String?, email: String?, confirmPassword: String?){
        let user = PFUser()
        if let username = username, let name = name, let password = password, let email = email{
            if username.count >= 3 && name.count >= 3 && password.count >= 6 && email.count >= 3 {
                if password == confirmPassword {
                    user.username = username
                    user.password = password
                    user.email = email
                    user["name"] = name
                    if let data = toView?.imageData {
                        user["photo"] = PFFile(name: (username + ".jpg"), data: data)
                    }
                    user.signUpInBackground(){ [weak self](result, error) in
                        if result, error == nil {
                            DispatchQueue.main.async {
                                Wireframe.dismiss(view: operatorVC)
                            }
                        }
                        else {
                            let item = DispatchWorkItem {
                                self?.toView?.errorText = error?.localizedDescription
                                print("workItemExecuted")
                            }
                            DispatchQueue.main.async(execute: item)
                            print ("Cannot sign up!")
                        }
                    }
                }
                else {
                    toView?.errorText = "Passwords must mutch"
                }
            }
            else {
                toView?.errorText = "All textfields must be more than 3 characters (password 6)"
            }
        }
        else {
            toView?.errorText = "All textfields must be filled"
        }
    }
    
}
