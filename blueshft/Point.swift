//
//  Point.swift
//  blueshft
//
//  Created by Kenny Schlagel on 10/3/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Point: PFObject {
    @NSManaged var parentId: String
    @NSManaged var name: String
    @NSManaged var coordinates: PFGeoPoint
    @NSManaged var details: String
    @NSManaged var type: Int
    
    
    init(parentId: String, name: String, coordinates: PFGeoPoint, details: String, type: Int) {
        super.init()

        self.parentId = parentId
        self.name = name
        self.coordinates = coordinates
        self.details = details
        self.type = type

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

extension Point: MKAnnotation {
    var title: String! {
        return name
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude)
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): name]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}