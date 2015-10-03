//
//  DetailViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/26/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit
import MapKit



class DetailViewController: UIViewController  {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    
    var tours = [Tour]() {
        didSet {
            // after we set a tour on our background thread we should call a method to display tour data on the map w animation
            print("total tours: \(self.tours)")
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
        self.mapView.delegate = self
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
            self.getTourPath()
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
                            }
                        }
                    }
                } else {
                    print("error: \(error)")
                }
            }
        }
    }
    
    func getTourPath() {
        var pointsToUse: [CLLocationCoordinate2D] = []
        
        pointsToUse += [CLLocationCoordinate2DMake(CLLocationDegrees(39.743480), CLLocationDegrees(-105.011304))]
        pointsToUse += [CLLocationCoordinate2DMake(CLLocationDegrees(39.744181), CLLocationDegrees(-105.008107))]
        pointsToUse += [CLLocationCoordinate2DMake(CLLocationDegrees(39.742787), CLLocationDegrees(-105.006337))]
        pointsToUse += [CLLocationCoordinate2DMake(CLLocationDegrees(39.742078), CLLocationDegrees(-105.004202))]

        var pointsCount = 4
        
        let myPolyline = MKPolyline(coordinates: &pointsToUse, count: pointsCount)
        
        mapView.addOverlay(myPolyline)

    }
    

}
extension DetailViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.grayColor()
            polylineRenderer.alpha = 0.7
            polylineRenderer.lineWidth = 4
            
            return polylineRenderer
        }
        return nil
    }
}