//
//  PointView.swift
//  blueshft
//
//  Created by Kenny Schlagel on 11/1/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit
import MapKit

class PointPin: UIView {

    @IBOutlet weak var pointDesc: UILabel!
    @IBOutlet weak var typeDesc: UILabel!
    
    var point: Point? {
        didSet {
            // maybe load array of images here?
        }
    }
    
    var detailVC: DetailViewController?

    @IBAction func seeMoreAboutPoint(sender: AnyObject) {
        if let point = self.point {
            detailVC?.showSimpleOverlayForPoint(point)
        }
    }
    
    @IBAction func getDirectionsToPoint(sender: AnyObject) {
        if let point = self.point {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            point.mapItem().openInMapsWithLaunchOptions(launchOptions)
        }
    }
}
