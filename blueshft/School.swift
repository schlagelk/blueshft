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
    @NSManaged var popMajors: String
    @NSManaged var classSize: String
    
    var location: String {
        return city + ", " + state
    }
    
    init(name: String, students: String, city: String, state: String, image: PFFile, headquarters: PFGeoPoint, classSize: String, popMajors: String) {
        super.init()
 
        self.name = name
        self.students = students
        self.city = city
        self.state = state
        self.image = image
        self.headquarters = headquarters
        self.popMajors = popMajors
        self.classSize = classSize
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: self.parseClassName())
        return query
    }
    
    func getCriteriaStringForLabel(label: UILabel) {
        let query = Criteria.query()
        query!.whereKey("parentId", equalTo: self.objectId!)
        query!.limit = 3
        query!.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let criteriums = objects as? [Criteria] {
                    let criteString = criteriums.reduce("") { (critestring, object) in critestring + "\(object.name): \(object.criteria) " }
                    label.text = criteString
                }
            } else {
                print("error: \(error)")
            }
            
        }
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