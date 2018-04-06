//
//  CreateAccountVC.swift
//  IWHERE
//
//  Created by Михаил on 05.12.2017.
//  Copyright © 2017 WorldCitizien. All rights reserved.
//

import UIKit
import Parse

class CreateAccountVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate ,UIImagePickerControllerDelegate, PresenterToViewCreateAccountProtocol {
    
    var presenter: ViewToPresenterCreateAccountPageProtocol? = PresenterCreateAccount()
    var setUpUI: SetUpViewProtocol? = SetUpView()
    
    var errorText: String?{
        get {
            return errorLabel.text
        }
        set {
            errorLabel.text = newValue
        }
    }
    
    var imageData: Data?{
        get {
            return imageView.image?.jpeg(.high)
        }
        set {
            if let data = newValue {
                imageView.image = UIImage(data: data)
            }
        }
    }

    @IBOutlet weak var mainSubView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameTexfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var StackCreate: UIStackView!
    @IBOutlet weak var createOrResetButton: UIButton!
    @IBOutlet weak var hatLabel: UINavigationItem!
    @IBOutlet weak var confirPasswordTextfield: UITextField!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.toView = self
        
        usernameTextField.delegate = self
        nameTexfield.delegate = self
        passwordTextField.delegate = self
        confirPasswordTextfield.delegate = self
        emailTextField.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        cosmeticSetUp()
    }

    @IBAction func selectImageTap(_ sender: UITapGestureRecognizer) {
        presenter?.choosePhotoActionAlert(operatorVC: self)
    }
    
    @IBAction func createButton(_ sender: UIButton) {
        presenter?.createUser(operatorVC: self, name: nameTexfield.text, username: usernameTextField.text, password: passwordTextField.text, email: emailTextField.text, confirmPassword: confirPasswordTextfield.text)
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        Wireframe.dismiss(view: self)
    }
    
    private func cosmeticSetUp(){
        setUpUI?.setUpImageView(arrayOfImageViews: [imageView])
        setUpUI?.setUpButtons(arrayOfButtons: [createOrResetButton])
        let arrayOfTextfields = [usernameTextField, nameTexfield, passwordTextField, confirPasswordTextfield, emailTextField]
        setUpUI?.setUpTextFields(arrayOfTextfields: arrayOfTextfields)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        presenter?.getImage(image: info[UIImagePickerControllerEditedImage] as? UIImage)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let responderCortege = (usernameTextField.isFirstResponder, nameTexfield.isFirstResponder, passwordTextField.isFirstResponder, confirPasswordTextfield.isFirstResponder ,emailTextField.isFirstResponder)
        switch responderCortege {
            case (true, false ,false, false, false): nameTexfield.becomeFirstResponder()
            case (false, true, false, false, false): passwordTextField.becomeFirstResponder()
            case (false, false, true, false, false): confirPasswordTextfield.becomeFirstResponder()
            case (false, false, false, true, false): emailTextField.becomeFirstResponder()
            case (false, false, false, false, true): emailTextField.resignFirstResponder()
            default: view.endEditing(true)
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.text = nil
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        presenter?.keyBoardHeightChanged(view: mainSubView, notification: notification)
    }
      // __________________________________________________________________________________<-
}
