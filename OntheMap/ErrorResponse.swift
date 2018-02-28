//
//  ErrorService.swift
//  OntheMap
//
//  Created by Fabiola Ramirez on 2/20/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import Foundation

struct ErrorResponse {
    
    //let code: Int
    let message: String
    
    init(message: String) {
        //self.code = code
        self.message = message
    }
    
}
