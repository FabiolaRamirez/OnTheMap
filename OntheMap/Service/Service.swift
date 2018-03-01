//
//  Services.swift
//  OntheMap
//
//  Created by Fabiola Ramirez on 2/18/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import Foundation
import UIKit

class Service {
    
   
    
    
    static func logIn(username: String, password: String, success: @escaping() -> (), failure: @escaping(_ errorResponse: ErrorResponse)-> ()) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            let parsedResult = try? JSONSerialization.jsonObject(with: newData!, options: .allowFragments)
            
            guard (error == nil) else {
                let e = ErrorResponse(message: "Request error: \(String(describing: error))")
                failure(e)
                return
            }
            
            guard let dictionary = parsedResult as? [String: Any] else {
                let e = ErrorResponse(message: "Can't Parse Dictionary")
                failure(e)
                
                return
            }
            
            guard let account = dictionary["account"] as? [String:Any] else {
                let e = ErrorResponse(message: "Cannot find key Account")
                failure(e)
                return
            }
            //data
            guard let userId = account["key"] as? String else {
                let e = ErrorResponse(message: "Cannot find key")
                failure(e)
                return
            }
            
            Preferences.saveUserId(key: userId)
            success()
            
        }
        
        task.resume()
        
    }
    
    static func getUserData(userId: String, success: @escaping() -> (), failure: @escaping(_ errorResponse: ErrorResponse)-> ()){
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/users/\(userId)")! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            
            guard (error == nil) else {
                let e = ErrorResponse(message: "Request error: \(String(describing: error))")
                failure(e)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let e = ErrorResponse(message: "Your Request Returned A Status Code Other Than 2..")
                failure(e)
                return
            }
            
            guard let data = data else {
                let e = ErrorResponse(message: "No Data Was Returned By The Request!")
                failure(e)
                return
            }
            
            //Parse
            let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments)
            } catch {
                let e = ErrorResponse(message: "Could not Parse The Data As JSON")
                failure(e)
                return
            }
            
            guard let dictionary = parsedResult as? [String: Any] else {
                let e = ErrorResponse(message: "Can not Parse")
                failure(e)
                return
            }
            
            
            guard let user = dictionary["user"] as? [String: Any] else {
                let e = ErrorResponse(message: "Cannot find Key user In parsedResult")
                failure(e)
                return
            }
            
            guard let lastName = user["last_name"] as? String else {
                let e = ErrorResponse(message: "Can not find Key")
                failure(e)
                return
            }
            
            //Utilize
            guard let firstName = user["first_name"] as? String else {
                let e = ErrorResponse(message: "Can not find Key")
                failure(e)
                return
            }
            
            Preferences.saveFirstName(firstName)
            Preferences.saveLastName(lastName)
            success()
        }
        task.resume()
        
    }
    
    static func getUsersData(success: @escaping() -> (), failure: @escaping(_ errorResponse: ErrorResponse)-> ()) {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt&limit=100")! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
    
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard (error == nil) else {
                let e = ErrorResponse(message: "There Was An Error With Your Request")
                failure(e)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let e = ErrorResponse(message: "our Request Returned A Status Code Other Than 2..")
                failure(e)
                return
            }
            
            guard let data = data else {
                let e = ErrorResponse(message: "No Data Was Returned By The Request")
                failure(e)
                return
            }
            
            //Parse
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                let e = ErrorResponse(message: "Could Not Parse The Data As JSON")
                failure(e)
                return
            }
            if let results = parsedResult as? [String: Any] {
                if let results = results["results"] as? [[String: Any]]{
                    var usersList = [User]()
                    for result in results {
                        if let User = User(dictionary: result) {
                            usersList.append(User)
                        }
                    }
                    UsersDataSource.shared.usersList = usersList
                    success()
                }
            } else {
                let e = ErrorResponse(message: "fail parsing..")
                failure(e)
                
            }
        }
        task.resume()
    }
    
    static func logOut(success: @escaping() -> (), failure: @escaping(_ errorResponse: ErrorResponse)-> ()) {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                let e = ErrorResponse(message: "Request error: \(String(describing: error))")
                failure(e)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let e = ErrorResponse(message: "Your Request Returned A Status Code Other Than 2..")
                failure(e)
                return
            }
            
            guard data != nil else {
                print("No Data Was Returned By The Request")
                return
            }
            success()
        }
        task.resume()
    }
    
    
    static func getExtraUserInfo(uniqueKey: String) {
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                Preferences.setIfOverride(false)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                Preferences.setIfOverride(false)
                return
            }
            
            guard let data = data else {
                Preferences.setIfOverride(false)
                return
            }
            
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            if let results = parsedResult as? [String: Any] {
                if let resultSet = results["results"] as? [[String: Any]]{
                    
                    let dics: [User] = Service.usersData(resultSet)
                    if dics.count > 0 {
                        let userOne =  dics[0]
                        Preferences.setIfOverride(true)
                        Preferences.saveFirstName(userOne.firstName)
                        Preferences.saveLastName(userOne.lastName)
                        Preferences.saveObjectId(userOne.objectId)
                        Preferences.saveUniqueKey(userOne.uniqueKey)
                    }
                }
            }
            
        }
        task.resume()
        
    }
    
    static func usersData(_ results: [[String:Any]]) -> [User] {
        var usersList = [User]()
        //Users Data Results
        for result in results {
            if let user = User(dictionary: result) {
                usersList.append(user)
            }
        }
        return usersList
    }
    
    
    static func postNew(student: User, location: String, success: @escaping() -> (), failure: @escaping(_ errorResponse: ErrorResponse)-> ()) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")! as URL)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.lat), \"longitude\": \(student.long)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            
            guard (error == nil) else {
                let e = ErrorResponse(message: "There was an error with your request: \(String(describing: error))")
                failure(e)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let e = ErrorResponse(message: "your request returned a status code other than 2..")
                failure(e)
                return
            }
            
            
            guard data != nil else {
                let e = ErrorResponse(message: "No data was returned by the request")
                failure(e)
                return
            }
            success()
        }
        task.resume()
        
    }
    
    static func updateUserData(student: User, location: String, success: @escaping() -> (), failure: @escaping(_ errorResponse: ErrorResponse)-> ()) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(student.objectId)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.lat), \"longitude\": \(student.long)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            
            guard (error == nil) else {
                let e = ErrorResponse(message: "There was an error with your request: \(String(describing: error))")
                failure(e)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let e = ErrorResponse(message: "Your request returned a status code other than 2..")
                failure(e)
                return
            }
            
            guard data != nil else {
                let e = ErrorResponse(message: "No data was returned by the request")
                failure(e)
                return
            }
            success()
            
        }
        task.resume()
        
    }
    
    
    
    
    
}
