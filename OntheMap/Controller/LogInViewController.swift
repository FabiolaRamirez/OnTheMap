//
//  LogInViewController.swift
//  OntheMap
//
//  Created by Fabiola Ramirez on 2/13/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    @IBAction func logIn(_ sender: UIButton) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            self.alertError(self, error: "Please enter information")
        } else {
            
            settingUI(true)
            Service.logIn(username: emailTextField.text!, password: passwordTextField.text!, success:{() in
                Service.getUserData(userId: Preferences.getUserId(), success: {() in
                    self.settingUI(false)
                    Service.getExtraUserInfo(uniqueKey: Preferences.getUserId())
                    self.openHomeScreen()
                    
                }, failure: {(error) in
                    self.settingUI(false)
                    DispatchQueue.main.async {
                    self.alertError(self, error: error.message)
                    }
                })
                
            }, failure: {(error) in
                self.settingUI(false)
                DispatchQueue.main.async {
                self.alertError(self, error: error.message)
                }
            })
        }
        
    }
    
    
    @IBAction func signUp(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!,
                                  options: [:], completionHandler: nil)
    }
    
    func openHomeScreen(){
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController : UITabBarController? = storyboard.instantiateViewController(withIdentifier: "rootViewController") as? UITabBarController
            self.present(viewController!, animated: true, completion: nil)
        }
    }
    
}

extension LogInViewController {
    
    func alertError(_ controller: UIViewController, error: String) {
        let AlertController = UIAlertController(title: "", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
            action in AlertController.dismiss(animated: true, completion: nil)
        }
        AlertController.addAction(cancelAction)
        controller.present(AlertController, animated: true, completion: nil)
    }
    
    func settingUI(_ value: Bool){
        if value{
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else{
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        
    }
    
    
}

extension LogInViewController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            emailTextField.text = ""
        } else {
            passwordTextField.text = ""
        }
    }
    
    
    // Move the view when the keyboard covers the textfield
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if passwordTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification) / 3
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue 
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
}


