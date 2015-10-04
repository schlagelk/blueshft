//
//  DetailViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/26/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit
import MapKit



class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    
    var tours = [Tour]() {
        didSet {
            // after we set a tour on our background thread we should call a method to display tour data on the map w animation
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
            // Update the view.
//            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        setLocationAndCenterOnMap()
        getToursForMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
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
        if items.count > 1 {
            let segControl = UISegmentedControl(items: items)
            segControl.selectedSegmentIndex = 0
            let frame = UIScreen.mainScreen().bounds
            segControl.frame = CGRectMake(frame.minX + 10, frame.minY + 50, frame.width - 20, frame.height*0.1)
            segControl.addTarget(self, action: "changeTour:", forControlEvents: .ValueChanged)
            self.view.addSubview(segControl)
        }
        idOfMapOnView = tourIds.first
    }
    
    func changeTour(sender: UISegmentedControl) {
        // reset the idofCurrentMap var
        let index = sender.selectedSegmentIndex
        let tourId = toursOnView[sender.titleForSegmentAtIndex(index)!] as! String!
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
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2DMake(castedPoint.coordinates.latitude, castedPoint.coordinates.longitude)
                            self.mapView.addAnnotation(annotation)
                        }
                    }
                }
            } else {
                print("error: \(error)")
            }
        }
    }
}

extension DetailViewController: MKMapViewDelegate {
}