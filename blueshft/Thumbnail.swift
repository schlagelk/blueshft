//
//  Image.swift
//  blueshft
//
//  Created by Kenny Schlagel on 11/9/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class Thumbnail: PFObject {
    
    @NSManaged var parentId: String
    @NSManaged var thumbnail: PFFile
    
    
    init(parentId: String, thumbnail: PFFile) {
        super.init()
        
        self.parentId = parentId
        self.thumbnail = thumbnail
        
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: self.parseClassName())
        return query
    }
}

extension Thumbnail: PFSubclassing {
    class func parseClassName() -> String {
        return "Thumbnail"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}
