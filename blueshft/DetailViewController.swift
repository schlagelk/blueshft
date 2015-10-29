//
//  DetailViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/26/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class DetailViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 550
    
    let simpleTransitionDelegate = SimpleTransitionDelegate()
    
    var tours = [Tour]() {
        didSet {
            print("total tours: \(self.tours)")
        }
    }
    
    var toursOnView = [String: String]()
    
    var idOfMapOnView: String? {
        didSet {
            addPointsToMap(self.idOfMapOnView!)
        }
    }
    
    var detailItem: School? {
        didSet {
            getToursForMap()
            self.navigationItem.title = detailItem?.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        segControl.removeAllSegments()
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.mapType = .HybridFlyover
        setLocationAndCenterOnMap()
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Map Stuff
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func setLocationAndCenterOnMap() {
        let lat = detailItem?.headquarters.latitude
        let long = detailItem?.headquarters.longitude

        if long != nil && lat != nil {
            let initialLocation = CLLocation(latitude: lat!, longitude: long!)
            centerMapOnLocation(initialLocation)
        }
    }
    
    func getToursForMap() {
        if self.detailItem?.objectId != nil {
            let query = Tour.query()
            let parentId: String = self.detailItem!.objectId!
            query!.whereKey("parentId", equalTo: parentId)

            query!.findObjectsInBackgroundWithBlock { (objects, error) in
                if error == nil {
                    if objects as? [Tour] != nil {
                        for tour in objects! {
                            if let castedTour = tour as? Tour {
                                self.tours.append(castedTour)
                                self.toursOnView[castedTour.tourName] = castedTour.objectId!
                            }
                        }
                        self.setTourNames()
                    }
                } else {
                    print("error: \(error)")
                }
            }
        }
    }
    
    func setTourNames() {
        var items: [String] = []
        var tourIds: [String] = []

        for (tourName, tourId) in toursOnView {
            items.append(tourName)
            tourIds.append(tourId)
        }
        segControl.removeAllSegments()
        if items.count > 1 {
            var x = 0
            for segmentItem in items {
                segControl.insertSegmentWithTitle(segmentItem, atIndex: ++x, animated: true)
            }
            segControl.selectedSegmentIndex = 0
            segControl.addTarget(self, action: "changeTour:", forControlEvents: .ValueChanged)
            segControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
            segControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        }
        idOfMapOnView = tourIds.first
    }
    
    func changeTour(sender: UISegmentedControl) {
        // reset the idofCurrentMap var
        let index = sender.selectedSegmentIndex
        let tourId = toursOnView[sender.titleForSegmentAtIndex(index)!]
        idOfMapOnView = tourId

    }
    
    func addPointsToMap(tourId: String) {
        //clear current annotations xcept for user position
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
        // fetch the points associated with this tour
        let query = Point.query()
        let parentId: String = tourId
        query!.whereKey("parentId", equalTo: parentId)
        
        query!.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if objects as? [Point] != nil {
                    for point in objects! {
                        if let castedPoint = point as? Point {
                            self.mapView.addAnnotation(castedPoint)
                        }
                    }
                }
            } else {
                print("error: \(error)")
            }
        }
    }
    
    func showSimpleOverlayForPoint(point: Point) {
        transitioningDelegate = simpleTransitionDelegate
        let overlay = self.storyboard?.instantiateViewControllerWithIdentifier("OverlayVC") as! OverlayViewController
        overlay.point = point
        overlay.view.backgroundColor = UIColor(white:1, alpha: 0.5)
        overlay.transitioningDelegate = simpleTransitionDelegate
        overlay.modalPresentationStyle = UIModalPresentationStyle.Custom
        presentViewController(overlay, animated: true, completion: nil)
        
    }
    
    func getDirectionsToPoint(point: Point) {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        point.mapItem().openInMapsWithLaunchOptions(launchOptions)

    }
}

extension DetailViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView?, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        guard annotation is MKUserLocation else {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView!.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
                view.animatesDrop = true
                view.pinTintColor = UIColor.cyanColor()
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let point = view.annotation as! Point
        showSimpleOverlayForPoint(point)
    }
}