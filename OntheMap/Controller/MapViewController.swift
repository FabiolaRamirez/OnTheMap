//
//  MapViewController.swift
//  OntheMap
//
//  Created by Fabiola Ramirez on 2/21/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var annotations = [MKPointAnnotation]()
    @IBOutlet weak var mapView: MKMapView!
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        self.mapView.delegate = self
        getUsersList()
        
    }
    
    
    func getUsersList() {
        settingUI(true)
        Service.getUsersData(success: { () in
            DispatchQueue.main.async {
                self.getUsersGeopoints()
                self.settingUI(false)
            }
        }, failure: {(error) in
            DispatchQueue.main.async {
            self.settingUI(false)
            self.alertError(self, error: error.message)
            }
        })
        
    }
    
    func getUsersGeopoints() {
        self.mapView.removeAnnotations(annotations)
        annotations = [MKPointAnnotation]()
        
        for dictionary in UsersDataSource.shared.usersList {
            let lat = dictionary.lat
            let long = dictionary.long
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let firstName = dictionary.firstName
            let lastName = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    @IBAction func registerLocation(_ sender: UIBarButtonItem) {
        
        let refreshAlert = UIAlertController(title: "", message: "User \(Preferences.getFirstName()) \(Preferences.getLastName()) Already posted a student location. Would you like to overwrite your current location?", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Overwride", style: .default, handler: { (action: UIAlertAction!) in
            let addressViewController = self.storyboard!.instantiateViewController(withIdentifier: "addressViewController") as! AddressViewController
            self.present(addressViewController, animated: true, completion: nil)
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        getUsersList()
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        settingUI(true)
        Service.logOut(success: {() in
            self.settingUI(false)
            self.dismiss(animated: true, completion: nil)
        }, failure: {(error) in
            self.settingUI(false)
            self.alertError(self, error: error.message)
        })
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

extension MapViewController {
    
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
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    func validateURL(_ url: String) -> Bool {
        if let url = URL(string: url) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if validateURL(toOpen){
                    app.openURL(URL(string: toOpen)!)
                } else {
                    self.alertError(self, error: "Invalid link")
                }
            }
        }
    }
}
