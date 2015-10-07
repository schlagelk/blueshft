//
//  Point.swift
//  blueshft
//
//  Created by Kenny Schlagel on 10/3/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import Foundation
import MapKit

class Point: PFObject {
    @NSManaged var parentId: String
    @NSManaged var name: String
    @NSManaged var coordinates: PFGeoPoint
    
    
    init(parentId: String, name: String, coordinates: PFGeoPoint) {
        super.init()

        self.parentId = parentId
        self.name = name
        self.coordinates = coordinates

    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: self.parseClassName())
        return query
    }
}

extension Point: PFSubclassing {
    class func parseClassName() -> String {
        return "Point"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}