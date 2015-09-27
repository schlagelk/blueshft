//
//  School.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/26/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import Foundation

class School {
    
    let name: String
    let enrollment: String
    let location: String
    
    init(name: String, enrollment: String, location: String) {
        self.name = name
        self.enrollment = enrollment
        self.location = location
    }
}

//extension School: PFSubclassing {
//    class func parseClassName() -> String {
//        return "School"
//    }
//    
//    override class func initialize() {
//        var onceToken: dispatch_once_t = 0
//        dispatch_once(&onceToken) {
//            self.registerSubclass()
//        }
//    }
//}