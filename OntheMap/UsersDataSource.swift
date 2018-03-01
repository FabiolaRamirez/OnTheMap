//
//  UsersDataSource.swift
//  OntheMap
//
//  Created by Fabiola Ramirez on 2/28/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import Foundation


class UsersDataSource {
    static let shared = UsersDataSource()
    
    var usersList: [User] = []
    
    
    private init() { }
}
