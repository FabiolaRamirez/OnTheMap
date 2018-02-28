//
//  Preferences.swift
//  OntheMap
//
//  Created by Fabiola Ramirez on 2/19/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import Foundation

class Preferences {
    
    
    static func getUserId() -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "UserId") ?? ""
    }
    
    
    static func saveUserId(key: String) {
        let defaults = UserDefaults.standard
        defaults.set(key, forKey: "UserId")
    }
    
    static func getUniqueKey() -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "UserUniqueKey") ?? ""
    }
    
    
    static func saveUniqueKey(_ key: String) {
        let defaults = UserDefaults.standard
        defaults.set(key, forKey: "UserUniqueKey")
    }
    
    static func getObjectId() -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "ObjectId") ?? ""
    }
    
    
    static func saveObjectId(_ key: String) {
        let defaults = UserDefaults.standard
        defaults.set(key, forKey: "ObjectId")
    }
    
    static func getFirstName() -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "UserFirstName") ?? ""
    }
    
    
    static func saveFirstName(_ firstName: String) {
        let defaults = UserDefaults.standard
        defaults.set(firstName, forKey: "UserFirstName")
    }
    
    static func getLastName() -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "UserLastName") ?? ""
    }
    
    
    static func saveLastName(_ lastName: String) {
        let defaults = UserDefaults.standard
        defaults.set(lastName, forKey: "UserLastName")
    }
    
    static func getIfOverride() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "override") 
    }
    
    
    static func setIfOverride(_ value: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "override")
    }
    
    
    
    
}
