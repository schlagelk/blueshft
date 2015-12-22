//
//  Criteria.swift
//  blueshft
//
//  Created by Kenny Schlagel on 12/22/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class Criteria: PFObject {
    
    @NSManaged var name: String
    @NSManaged var criteria: String
    @NSManaged var parentId: String
    
    init(name: String, parentId: String, criteria: String) {
        super.init()
        
        self.name = name
        self.parentId = parentId
        self.criteria = criteria
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: self.parseClassName())
        return query
    }
}

extension Criteria: PFSubclassing {
    class func parseClassName() -> String {
        return "Criteria"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}
