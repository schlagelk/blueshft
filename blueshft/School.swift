//
//  School.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/26/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import Foundation

class School: PFObject {
    
    @NSManaged var name: String
    @NSManaged var enrollment: String
    @NSManaged var location: String
    @NSManaged var image: PFFile
    
    init(name: String, enrollment: String, city: String, state: String, image: PFFile) {
        super.init()
        
        var locationString = city
        locationString += ", "
        locationString += state
        
        self.name = name
        self.enrollment = enrollment
        self.location = locationString
        self.image = image
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: self.parseClassName())
        query.orderByDescending("createdAt")
        return query
    }
}

extension School: PFSubclassing {
    class func parseClassName() -> String {
        return "School"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}