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

    @IBAction func getDirectionsToPoint(sender: AnyObject) {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        self.point?.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
}
