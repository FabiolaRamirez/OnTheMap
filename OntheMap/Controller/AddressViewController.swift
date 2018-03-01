//
//  AddressViewController.swift
//  OntheMap
//
//  Created by Fabiola Ramirez on 2/25/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import UIKit
import MapKit

class AddressViewController: UIViewController {
    
    
    @IBOutlet weak var addressTextField: UITextField!
    var activityIndicator = UIActivityIndicatorView()
    
    var latitude: Double = 0.00
    var longitude: Double = 0.00
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        addressTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func findAddress(_ sender: UIButton) {
        
        
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = addressTextField.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        
        if  addressTextField.text == "" {
            
            self.alert(self, message: "Please enter your studing's address")
        } else {
            settingUI(true)
            localSearch.start { (localSearchResponse, error) -> Void in
                
                if localSearchResponse == nil{
                    self.alert(self, message: "Failed To Geocode")
                    self.settingUI(false)
                    return
                }
                
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.title = self.addressTextField.text!
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
                
                self.latitude = localSearchResponse!.boundingRegion.center.latitude
                self.longitude = localSearchResponse!.boundingRegion.center.longitude
                
                
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "linkViewController") as! LinkViewController
                controller.location = self.addressTextField.text!
                controller.pointAnnotation = pointAnnotation
                controller.latitude = self.latitude
                controller.longitude = self.longitude
                self.settingUI(false)
                self.present(controller, animated: true, completion: nil)
            }
        }
        
    }
    
    
    @IBAction func pressOutside(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}

extension AddressViewController: UITextFieldDelegate {
    
    /*func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }*/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       addressTextField.text = ""
    }
    
    
    // Move the view when the keyboard covers the textfield
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if addressTextField.isFirstResponder {
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


extension AddressViewController {
    
    func alert(_ controller: UIViewController, message: String) {
        let AlertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
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
