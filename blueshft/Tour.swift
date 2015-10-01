//
//  Tour.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/30/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import Foundation

class Tour: PFObject {
    
    @NSManaged var parentId: String
    @NSManaged var tourPath: String

    
    init(parentId: String, tourPath: String) {
        super.init()
        
        self.parentId = parentId
        self.tourPath = tourPath

    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: self.parseClassName())
        return query
    }
}

extension Tour: PFSubclassing {
    class func parseClassName() -> String {
        return "Tour"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}