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
    @NSManaged var photo: PFFile
    @NSManaged var text: String
    @NSManaged var likes: Int
    @NSManaged var favs: Int
    
    
    init(parentId: String, photo: PFFile, text: String, likes: Int, favs: Int) {
        super.init()
        
        self.parentId = parentId
        self.photo = photo
        self.text = text
        self.likes = likes
        self.favs = favs
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