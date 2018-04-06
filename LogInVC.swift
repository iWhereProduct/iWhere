//
//  LogInVC.swift
//  IWHERE
//
//  Created by Михаил on 05.12.2017.
//  Copyright © 2017 WorldCitizien. All rights reserved.
//

import UIKit

class LogInVC: UIViewController, UITextFieldDelegate, PresenterToViewLogInPageProtocol {
    
    var segueIndentificator: String = "show"
    var presenter: ViewToPresenterLogInPageProtocol? = PresenterLogin()
    var setUpUI: SetUpViewProtocol? = SetUpView()
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorPassowrdLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.toView = self
        
        self.loginTextField.delegate = self
        self.passwordTextField.delegate = self
        cosmeticSetUp()
    }
    
    
    private func cosmeticSetUp(){
        setUpUI?.setUpTextFields(arrayOfTextfields: [loginTextField, passwordTextField])
        setUpUI?.setUpButtons(arrayOfButtons: [signUpButton])
        logInButton.layer.cornerRadius = 25
    }
    
    
    @IBAction func logButton(_ sender: UIButton) {
        presenter?.checkUsernameAndPasswordTextfield(username: loginTextField.text, password: passwordTextField.text)
    }
    
    @IBAction func resetPasswordAction(_ sender: UIButton) {
        presenter?.resetPassword(presenterView: self)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        presenter?.clearLabels()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if loginTextField.isFirstResponder{
            passwordTextField.becomeFirstResponder()
        }
        else{
            passwordTextField.resignFirstResponder()
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    var errorLabelText: String? {
        get{
            return errorLabel.text
        }
        set {
            errorLabel.text = newValue
        }
    }
    
    var errorPasswordText: String? {
        get{
            return errorPassowrdLabel.text
        }
        set {
            errorPassowrdLabel.text = newValue
        }
    }
    
}
