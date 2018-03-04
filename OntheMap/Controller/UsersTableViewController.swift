//
//  UsersTableViewController.swift
//  OntheMap
//
//  Created by Fabiola Ramirez on 2/22/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    var activityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        loadUsersList()
        
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
    
    
    func loadUsersList(){
        settingUI(true)
        Service.getUsersData(success: {() in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.settingUI(false)
            }
        }, failure: {(error) in
            self.settingUI(false)
            self.alertError(self, error: error.message)
            
        })
        
    }
    
    
    @IBAction func registerData(_ sender: UIBarButtonItem) {
        
        let refreshAlert = UIAlertController(title: "", message: "User \(Preferences.getFirstName()) \(Preferences.getLastName()) Already posted a student location. Would you like to overwrite your current location?", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Overwride", style: .default, handler: { (action: UIAlertAction!) in
            let addressViewController = self.storyboard!.instantiateViewController(withIdentifier: "addressViewController") as! AddressViewController
            self.present(addressViewController, animated: true, completion: nil)
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return UsersDataSource.shared.usersList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        let user = UsersDataSource.shared.usersList[indexPath.row]
        
        cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
        cell.webpageLabel.text = user.mediaURL
        
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let user = UsersDataSource.shared.usersList[indexPath.row]
        
        let app = UIApplication.shared
        if validateURL(user.mediaURL){
            app.open(URL(string: user.mediaURL)!, options: [:], completionHandler: nil)
            
        } else {
            self.alertError(self, error: "Invalid Link")
        }
    }
    
}

extension UsersTableViewController {
    
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
    
    func validateURL(_ url: String) -> Bool {
        if let url = URL(string: url) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
}

