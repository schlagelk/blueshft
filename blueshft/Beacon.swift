//
//  Beacon.swift
//  blueshft
//
//  Created by Kenny Schlagel on 12/18/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class Beacon: PFObject {
    
    @NSManaged var name: String
    @NSManaged var subTitle: String
    @NSManaged var image: PFFile?
    @NSManaged var parentId: String
    @NSManaged var major: String
    @NSManaged var minor: String
    
    init(name: String, image: PFFile?, parentId: String, subTitle: String, major: String, minor: String) {
        super.init()
        
        self.name = name
        self.image = image
        self.parentId = parentId
        self.subTitle = subTitle
        self.major = major
        self.minor = minor
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: self.parseClassName())
        return query
    }
}

extension Beacon: PFSubclassing {
    class func parseClassName() -> String {
        return "Beacon"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}