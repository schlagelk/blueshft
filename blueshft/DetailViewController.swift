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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var beaconButton: UIBarButtonItem!
    
    @IBAction func beaconButtonPressed(sender: AnyObject) {
        print("show beacons")
    }
    
    lazy var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 500
    
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
    
    //probably just make this of type [clbeacon] or whatever
    var beacons: [Int] = [1,2,3]
    
    func setupBeacons() {
        beaconButton.enabled = false
        if self.beacons.isEmpty { return } else {
            beaconButton.enabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        segControl.removeAllSegments()
        setupMap()
        setLocationAndCenterOnMap()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "isUserLoggedIn:", name: "BSUserLoggedInNotification", object: nil)
        setupBeacons()
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func isUserLoggedIn(notification: NSNotification?) {
        if (PFUser.currentUser() == nil) {
            logoutButton.enabled = false
        } else {
            logoutButton.enabled = true
        }
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
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() == nil) {
            logoutButton.enabled = false
        } else {
            logoutButton.enabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DetailViewController: MKMapViewDelegate {
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func setupMap() {
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.mapType = .HybridFlyover
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
        overlay.transitioningDelegate = simpleTransitionDelegate
        overlay.modalPresentationStyle = UIModalPresentationStyle.Custom
        presentViewController(overlay, animated: true, completion: nil)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Point else { return nil }
        
        let identifier = "PointPin"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        }
        
        annotationView!.annotation = annotation
        annotationView!.animatesDrop = true
        
        let detailView = UIView.loadFromNibNamed(identifier) as! PointPin
        detailView.pointDesc.text = annotation.details
        annotationView!.detailCalloutAccessoryView = detailView
        detailView.point = annotation
        detailView.detailVC = self
        
        // set colors for map annotations and details
        // need to figure out colors and shit
        switch annotation.type {
        case 4:
            let color = UIColor.cyanColor()
            annotationView!.pinTintColor = color
            detailView.typeDesc.backgroundColor = color
            detailView.typeDesc.text = "Arts"
        case 3:
            let color = UIColor.blackColor()
            annotationView!.pinTintColor = color
            detailView.typeDesc.backgroundColor = color
            detailView.typeDesc.text = "Academic"
        case 2:
            let color = UIColor.orangeColor()
            annotationView!.pinTintColor = color
            detailView.typeDesc.backgroundColor = color
            detailView.typeDesc.text = "Life"
        default:
            let color = UIColor.blueColor()
            annotationView!.pinTintColor = color
            detailView.typeDesc.backgroundColor = color
            detailView.typeDesc.text = "All Purpose"
        }
        return annotationView
    }
}

// #pragma mark - UIAdaptivePresentationControllerDelegate
extension DetailViewController: UIPopoverPresentationControllerDelegate {
    
    @IBAction func logoutPressed(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let contentViewController: PopupViewController = storyboard.instantiateViewControllerWithIdentifier("PopupViewController") as! PopupViewController
        contentViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        contentViewController.userButton = self.logoutButton
        contentViewController.preferredContentSize = CGSize(width: 320, height: 200)

        let detailPopover: UIPopoverPresentationController = contentViewController.popoverPresentationController!
        detailPopover.barButtonItem = sender as? UIBarButtonItem
        detailPopover.permittedArrowDirections = UIPopoverArrowDirection.Any
        detailPopover.delegate = self
        
        presentViewController(contentViewController, animated: true, completion:nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
            return UIModalPresentationStyle.None
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        return navController
    }
}