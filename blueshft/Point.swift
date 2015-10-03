//
//  Point.swift
//  blueshft
//
//  Created by Kenny Schlagel on 10/3/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import Foundation
import MapKit

class Point: PFObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    @NSManaged var parentId: String
    @NSManaged var name: String
    @NSManaged var coordinates: PFGeoPoint
    
    
    init(parentId: String, name: String, coordinates: PFGeoPoint) {
        self.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        super.init()
        
        self.parentId = parentId
        self.name = name
        self.coordinates = coordinates
        
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

extension Point: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Point {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
}