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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var stickyStudentsLabel: UILabel!
    @IBOutlet weak var stickyNameLabel: UILabel!
    @IBOutlet weak var stickyLocationLabel: UILabel!
    
    @IBOutlet weak var stickyCriteriaLabel: UILabel!
    
    @IBOutlet weak var showStickyButton: UIButton!
    @IBAction func showStickyPressed(sender: AnyObject) {
        self.tagView.hidden = false
        self.showStickyButton.hidden = true
    }
    
    @IBAction func closeStickyPressed(sender: AnyObject) {
        self.tagView.hidden = true
        self.showStickyButton.hidden = false
    }
    
    private var animator: UIDynamicAnimator!
    var stickyBehavior: StickyEdgesBehavior!
    private var offset = CGPoint.zero
    
    lazy var locationManager = CLLocationManager()
    lazy var currentLocation = CLLocation()

    let regionRadius: CLLocationDistance = 500
    let distanceInMetersToActivateBeacons = 3000.00
    
    let simpleTransitionDelegate = SimpleTransitionDelegate()
    
    var tours = [Tour]() {
        didSet {
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
            setupBeacons()
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
        setUpSticky()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.detailItem != nil {
            stickyBehavior.isEnabled = false
            stickyBehavior.updateFieldsInBounds(containerView.bounds)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupBeacons() {
        beaconButton.enabled = false
        guard self.detailItem?.headquarters.longitude != nil && self.detailItem?.headquarters.latitude != nil else { return }
        if let currentLocationExists = locationManager.location {
            let castedLocationOfSchool = CLLocation(latitude: (self.detailItem?.headquarters.latitude)!, longitude:(self.detailItem?.headquarters.longitude)!)
            currentLocation = locationManager.location!
            let distanceToSchool = currentLocation.distanceFromLocation(castedLocationOfSchool)
            if distanceToSchool < distanceInMetersToActivateBeacons {
                beaconButton.enabled = true
                // startRangingBeaconsInRegion
                // range should be tour unique id
                // or can i make the popup the cl delegate using this class locationManager reference?
            }
        }
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
    
    // MARK: sticky
    func setUpSticky() {
        self.showStickyButton.hidden = true
        if self.detailItem != nil {
            tagView.hidden = false
            tagView.layer.cornerRadius = 2
            
            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
            tagView.addGestureRecognizer(gestureRecognizer)
            
            animator = UIDynamicAnimator(referenceView: containerView)
            stickyBehavior = StickyEdgesBehavior(item: tagView, edgeInset: 8)
            animator.addBehavior(stickyBehavior)
            stickyStudentsLabel.text = self.detailItem?.students
            stickyNameLabel.text = self.detailItem?.name
            stickyLocationLabel.text = self.detailItem?.location
            
            //copy and pasted this crap. bleh
            if let objectID = self.detailItem?.objectId {
                let query = Criteria.query()
                query!.whereKey("parentId", equalTo: objectID)
                query!.findObjectsInBackgroundWithBlock { (objects, error) in
                    if error == nil {
                        if let criteriums = objects as? [Criteria] {
                            let criteString = criteriums.reduce("| ") { (critestring, object) in critestring + "\(object.name): \(object.criteria) | " }
                            self.stickyCriteriaLabel.text = criteString
                        }
                    } else {
                        print("error: \(error)")
                    }
                    
                }
            }
        } else {
            tagView.hidden = true
        }
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        var location = pan.locationInView(containerView)
        
        switch pan.state {
        case .Began:
            let center = tagView.center
            offset.x = location.x - center.x
            offset.y = location.y - center.y
            
            stickyBehavior.isEnabled = false
            
        case .Changed:
            let referenceBounds = containerView.bounds
            let referenceWidth = referenceBounds.width
            let referenceHeight = referenceBounds.height
            
            let itemBounds = tagView.bounds
            let itemHalfWidth = itemBounds.width / 2.0
            let itemHalfHeight = itemBounds.height / 2.0
            
            location.x -= offset.x
            location.y -= offset.y
            
            location.x = max(itemHalfWidth, location.x)
            location.x = min(referenceWidth - itemHalfWidth, location.x)
            location.y = max(itemHalfHeight, location.y)
            location.y = min(referenceHeight - itemHalfHeight, location.y)
            
            tagView.center = location
        case .Cancelled, .Ended:
            let velocity = pan.velocityInView(containerView)
            stickyBehavior.isEnabled = true
            stickyBehavior.addLinearVelocity(velocity)
        default: ()
        }
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
//        switch annotation.type {
//        case 4:
//            let color = UIColor.cyanColor()
//            annotationView!.pinTintColor = color
//            detailView.typeDesc.backgroundColor = color
//            detailView.typeDesc.text = "Arts"
//        case 3:
//            let color = UIColor.blackColor()
//            annotationView!.pinTintColor = color
//            detailView.typeDesc.backgroundColor = color
//            detailView.typeDesc.text = "Academic"
//        case 2:
//            let color = UIColor.orangeColor()
//            annotationView!.pinTintColor = color
//            detailView.typeDesc.backgroundColor = color
//            detailView.typeDesc.text = "Life"
//        default:
//            let color = UIColor.blueColor()
//            annotationView!.pinTintColor = color
//            detailView.typeDesc.backgroundColor = color
//            detailView.typeDesc.text = "All Purpose"
//        }
        return annotationView
    }
}

// MARK: Popover stuff
extension DetailViewController: UIPopoverPresentationControllerDelegate {
    
    @IBAction func logoutPressed(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let contentViewController: PopupViewController = storyboard.instantiateViewControllerWithIdentifier("PopupViewController") as! PopupViewController
        contentViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        contentViewController.userButton = self.logoutButton
        contentViewController.preferredContentSize = CGSize(width: 320, height: 260)

        let detailPopover: UIPopoverPresentationController = contentViewController.popoverPresentationController!
        detailPopover.barButtonItem = sender as? UIBarButtonItem
        detailPopover.permittedArrowDirections = UIPopoverArrowDirection.Any
        detailPopover.delegate = self
        
        presentViewController(contentViewController, animated: true, completion:nil)
    }
    
    @IBAction func beaconButtonPressed(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let contentViewController: BeaconsViewController = storyboard.instantiateViewControllerWithIdentifier("BeaconsViewController") as! BeaconsViewController
        contentViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        contentViewController.preferredContentSize = CGSize(width: 320, height: 460)
        var testingPassingData: [Beacon]?
        if var testingPassingData = testingPassingData {
            contentViewController.beacons = testingPassingData
        }
        
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