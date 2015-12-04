//
//  PointView.swift
//  blueshft
//
//  Created by Kenny Schlagel on 11/1/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation


class PointPin: UIView {

    @IBOutlet weak var pointDesc: UILabel!
    @IBOutlet weak var typeDesc: UILabel!
    @IBOutlet weak var talkButton: UIButton!
    @IBOutlet weak var stopTalkButton: UIButton!
    
    let synthesizer = AVSpeechSynthesizer()
    
    var point: Point? {
        didSet {

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
    @IBAction func speak(sender: AnyObject) {
        if let point = self.point {
            let utterance = AVSpeechUtterance(string: point.details)
            synthesizer.speakUtterance(utterance)
            animateButtonAppearanceForSpeech(true)
        }
    }
    
    @IBAction func stopSpeek(sender: AnyObject) {
        synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        animateButtonAppearanceForSpeech(false)
    }
    
    func animateButtonAppearanceForSpeech(shouldHideSpeakButton: Bool) {
        var speakButtonAlpha: CGFloat = 1.0
        var stopButtonAlpha: CGFloat = 0.0
        
        if shouldHideSpeakButton {
            speakButtonAlpha = 0.0
            self.talkButton.hidden = true
            stopButtonAlpha = 1.0
            self.stopTalkButton.hidden = false
        } else {
            speakButtonAlpha = 1.0
            self.talkButton.hidden = false
            stopButtonAlpha = 0.0
            self.stopTalkButton.hidden = true
        }
        
        UIView.animateWithDuration(0.10, animations: { ()-> Void in
            self.talkButton.alpha = speakButtonAlpha
            self.stopTalkButton.alpha = stopButtonAlpha
        })
    }
}
