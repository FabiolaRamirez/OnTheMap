//
//  LinkViewController.swift
//  OntheMap
//
//  Created by Fabiola Ramirez on 2/25/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import UIKit
import MapKit

class LinkViewController: UIViewController {
    
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var activityIndicator = UIActivityIndicatorView()
    
    
    var mediaURL: String = ""
    var pointAnnotation = MKPointAnnotation()
    var location: String = ""
    var latitude: Double = 0.00
    var longitude: Double = 0.00
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        linkTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: pointAnnotation.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.centerCoordinate = pointAnnotation.coordinate
        self.mapView.addAnnotation(pinAnnotationView.annotation!)
        self.mapView.delegate = self as? MKMapViewDelegate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func submit(_ sender: UIButton) {
        let userData = User(dictionary: ["firstName" : Preferences.getFirstName() as AnyObject, "lastName": Preferences.getLastName() as AnyObject, "mediaURL": linkTextField.text as AnyObject, "latitude": latitude as AnyObject, "longitude": longitude as AnyObject, "objectId": Preferences.getObjectId() as AnyObject, "uniqueKey": Preferences.getUniqueKey() as AnyObject])
        
        if  linkTextField.text == "" {
            self.alertError(self, error: "Please enter a link")
        } else {
            if validateURL(linkTextField.text!) == true {
                if Preferences.getIfOverride() {
                    settingUI(true)
                    Service.updateUserData(student: userData!, location: location, success: {() in
                        DispatchQueue.main.async{
                            self.settingUI(false)
                            self.openMapScreen()
                        }
                    }, failure: {(error) in
                        self.settingUI(false)
                        self.alertError(self, error: error.message)
                    })
                    
                } else {
                    settingUI(true)
                    Service.postNew(student: userData!, location: location, success: {() in
                        DispatchQueue.main.async{
                            self.settingUI(false)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController : UITabBarController? = storyboard.instantiateViewController(withIdentifier: "rootViewController") as? UITabBarController
                            self.present(viewController!, animated: true, completion: nil)
                            
                        }
                    }, failure: { (error) in
                        self.settingUI(false)
                        self.alertError(self, error: error.message)
                    })
                    
                }
                
            } else {
                self.alertError(self, error: "Invalid URL")
            }
        }
    }
    
    func openMapScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController : UITabBarController? = storyboard.instantiateViewController(withIdentifier: "rootViewController") as? UITabBarController
        self.present(viewController!, animated: true, completion: nil)
    }
    
    @IBAction func pressOutside(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}

extension LinkViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension LinkViewController {
    
    func alertError(_ controller: UIViewController, error: String) {
        let AlertController = UIAlertController(title: "", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
            action in AlertController.dismiss(animated: true, completion: nil)
        }
        AlertController.addAction(cancelAction)
        controller.present(AlertController, animated: true, completion: nil)
    }
    
    
    func validateURL(_ url: String) -> Bool {
        if let url = URL(string: url) {
            return true
        }
        return false
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
