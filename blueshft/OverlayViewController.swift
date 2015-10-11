/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class OverlayViewController: UIViewController {
  

    var contentContainerView: UIView = UIView()
    var pointNameLabel: UILabel = UILabel()
    var closeButton: UIButton = UIButton()
    var point: Point?

    init(point: Point) {
        super.init(nibName: nil, bundle: nil)
        self.point = point
        modalPresentationStyle = UIModalPresentationStyle.Custom
        configureUIElements()
    }

    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pointNameLabel.text = "Name: " + point!.name
        print("text should be \(pointNameLabel.text)")
    }
    func configureUIElements() {
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        contentContainerView.layer.cornerRadius = 5.0;
        view.addSubview(contentContainerView)
        
        // Set default values for font sizes
        // and constraints for a smaller screen.
        var titleFontSize: CGFloat = 24.0
        var labelFontSize: CGFloat = 10.0
        var horizontalSpacing: NSNumber = 10
        var containerHeight: NSNumber = 160
        var containerTopSpacing: NSNumber = 5
        var containerBottomSpacing: NSNumber = 5
        var itemSpacing: NSNumber = 5
        var maxSpacing: NSNumber = 5
        
        // If there is more screen space available,
        // then increase the values to use the space.
        if view.bounds.size.width > 568.0 {
            titleFontSize = 42.0
            labelFontSize = 18.0
            horizontalSpacing = 60
            containerHeight = 350
            containerTopSpacing = 20
            containerBottomSpacing = 60
            itemSpacing = 20
            maxSpacing = 200
        }
        addToViewAndApplyStylingAndFontSize(titleFontSize, label: pointNameLabel)
        closeButton.setTitle("Close", forState: UIControlState.Normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = UIColor.whiteColor()
        closeButton.titleLabel!.font = UIFont.systemFontOfSize(labelFontSize)
        closeButton.addTarget(self, action: "closeButtonPressed:",
            forControlEvents: UIControlEvents.TouchUpInside)
        
        contentContainerView.addSubview(closeButton)
        
        let views = [
            "contentContainerView": contentContainerView,
            "pointNameLabel": pointNameLabel,
            "closeButton": closeButton]
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-(spacing)-[contentContainerView]-(spacing)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: ["spacing": horizontalSpacing],
                views: views))
        
        contentContainerView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-[pointNameLabel]-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views))
        
        contentContainerView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-[closeButton]-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views))
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-(>=containerTopSpacing)-[contentContainerView(containerHeight)]" +
                "-(containerBottomSpacing)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: ["containerHeight": containerHeight,
                    "containerTopSpacing": containerTopSpacing,
                    "containerBottomSpacing": containerBottomSpacing],
                views: views))
        
        contentContainerView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-(itemSpacing)-[pointNameLabel]-(<=maxSpacing)-[closeButton]-(itemSpacing)-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: ["itemSpacing": itemSpacing,
                    "maxSpacing": maxSpacing],
                views: views))
    }
    
    func addToViewAndApplyStylingAndFontSize(fontSize: CGFloat,
        label: UILabel) {
            
            // Helper method to configure label and add to view.
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = UIColor.clearColor()
            label.font = UIFont.boldSystemFontOfSize(fontSize)
            label.textColor = UIColor.whiteColor()
            
            contentContainerView.addSubview(label)
    }
    
    func closeButtonPressed(sender: UIButton) {
        presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
}
