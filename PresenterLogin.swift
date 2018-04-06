//
//  InteractorLogin.swift
//  IWHERE
//
//  Created by Михаил on 31.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import Parse
import UIKit

class PresenterLogin: NSObject, ViewToPresenterLogInPageProtocol {
    
    public weak var toView: PresenterToViewLogInPageProtocol?

    
    internal func checkUsernameAndPasswordTextfield(username: String?, password: String?) {
        var resultUsername = false
        var resultPassword = false
        
        if let usernameText = username {
            if usernameText.count >= 3 {
                resultUsername = true
            }
            else {
                toView?.errorLabelText = "Username should be more than 6 simbols"
            }
        }
        else{
            toView?.errorLabelText = "Login textfield should not be empty"
        }
        
        if let passwordText = password {
            if passwordText.count >= 6 {
                resultPassword = true
            }
            else {
                toView?.errorPasswordText = "Password should be more than 6 simbols"
            }
        }
        else{
            toView?.errorPasswordText = "Pasword textfield should not be empty"
        }
        if resultUsername == true && resultPassword == true {
            logIn(username: username!, password: password!)
        }
    }
    
    private func logIn(username: String, password: String) {
        PFUser.logInWithUsername(inBackground: username, password: password){[weak self] (user, error) in
            if error == nil && user != nil {
                print("Log in succesed")
                UserDefaults.standard.set(username, forKey: "login")
                UserDefaults.standard.set(password, forKey: "password")
                if let viewController = self?.toView as? UIViewController, let inditificator = self?.toView?.segueIndentificator {
                    Wireframe.performSegue(from: viewController, toSegueIndentificator: inditificator)
                }
            }
            else {
                print("Log in failed")
                self?.toView?.errorLabelText = "Incorrect username or password"
                self?.toView?.errorPasswordText = nil
            }
        }
    }
    
    internal func resetPassword(presenterView: UIViewController) {
        let alertController = UIAlertController(title: "Reset Password", message: "Write your email", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let acceptAction = UIAlertAction(title: "Send", style: .default) { [weak self] (action) in
            if let text = alertController.textFields?[0].text{
                if text.count >= 6 {
                    PFUser.requestPasswordResetForEmail(inBackground: text)
                    alertController.dismiss(animated: true, completion: nil)
                    self?.informationAlert(presenter: presenterView)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(acceptAction)
        alertController.addAction(cancelAction)
        presenterView.present(alertController, animated: true, completion: nil)
    }
    
    
    private func informationAlert(presenter: UIViewController) {
        let alertController = UIAlertController(title: "Email was sended", message: "Check your mail inboxes.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        presenter.present(alertController, animated: true, completion: nil)
    }
    
    internal func clearLabels(){
        toView?.errorLabelText = nil
        toView?.errorPasswordText = nil
    }
}



