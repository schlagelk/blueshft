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
    @NSManaged var students: String
    @NSManaged var city: String
    @NSManaged var state: String
    @NSManaged var image: PFFile
    @NSManaged var headquarters: PFGeoPoint
    
    init(name: String, students: String, city: String, state: String, image: PFFile, headquarters: PFGeoPoint) {
        super.init()
        
        self.name = name
        self.students = students
        self.city = city
        self.state = state
        self.image = image
        self.headquarters = headquarters
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: self.parseClassName())
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