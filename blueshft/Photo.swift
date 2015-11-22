//
//  Photo.swift
//  blueshft
//
//  Created by Kenny Schlagel on 11/16/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import Foundation

class Photo: PFObject {
    
    @NSManaged var parentId: String
    @NSManaged var pic: PFFile
    @NSManaged var text: String
    @NSManaged var likes: Int
    
    
    init(parentId: String, pic: PFFile, text: String, likes: Int) {
        super.init()
        
        self.parentId = parentId
        self.pic = pic
        self.text = text
        self.likes = likes
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: self.parseClassName())
        return query
    }
}

extension Photo: PFSubclassing {
    class func parseClassName() -> String {
        return "Photo"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}