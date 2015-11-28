//
//  PhotoViewerViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 11/16/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit
import QuartzCore

class PhotoViewerViewController: UIViewController, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
    var parentId: String! // Is set by the collection view while performing a segue to this controller
    
    let scrollView = UIScrollView()
    let imageView = PFImageView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    // add init?
    var photoInfo: Photo?
    var image: PFFile?
    var pointName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupView()
        loadPhoto()
    }
    
    func setupView() {
        // Visual feedback to the user, so they know we're busy loading an image
        spinner.center = CGPoint(x: view.center.x, y: view.center.y - view.bounds.origin.y / 2.0)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        view.addSubview(spinner)
        
        // A scroll view is used to allow zooming
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        view.addSubview(scrollView)
        
        imageView.contentMode = .ScaleAspectFill
        scrollView.addSubview(imageView)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
    }
    
    func loadPhoto() {
        
        imageView.image = nil
        let query = Photo.query()
        if let parentId = self.parentId {
            query!.whereKey("parentId", equalTo: parentId)
            query?.limit = 1
            do {
                let objects = try query?.findObjects() as! [Photo]
                self.photoInfo = objects.first
                self.image = objects.first?.pic
            } catch {
                print(error)
            }
        }
        addButtomBar()
        imageView.file = self.image
        imageView.loadInBackground {(image: UIImage?, error: NSError?) ->Void in
            if error == nil {
                if let leImage = image {
                    self.imageView.image = leImage
                    self.imageView.frame = self.centerFrameFromImage(self.imageView.image)
                    self.spinner.stopAnimating()
                    self.centerScrollViewContents()
                }
            } else {
                print("problem loading image \(error)")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Bottom Bar
    
    func addButtomBar() {
        var items = [UIBarButtonItem]()
        let myToolbar: UIToolbar = UIToolbar()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        items.append(barButtonItemWithImageNamed("back", title: nil, action: "goBack"))
        
        items.append(flexibleSpace)
        let barButt = UIBarButtonItem(title: self.pointName, style: .Plain, target:nil, action:nil)
        items.append(barButt)
        items.append(flexibleSpace)
        
        let likes = photoInfo?.likes ?? 0
        if likes > 0 {
            let likesToView = String(likes)
            items.append(barButtonItemWithImageNamed("like", title: likesToView))
        } else {
            let likesToView = String(likes)
            items.append(barButtonItemWithImageNamed("like", title: nil))
        }

        myToolbar.frame = CGRectMake(0, self.view.frame.height - 44, self.view.frame.size.width, 44)
        myToolbar.items = items
        myToolbar.barTintColor = UIColor.blackColor()
        myToolbar.opaque = false
        self.view.addSubview(myToolbar)

    }
    
    func goBack() {
        presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showComments() {
//        let photoCommentsViewController = storyboard?.instantiateViewControllerWithIdentifier("PhotoComments") as? PhotoCommentsViewController
//        photoCommentsViewController?.modalPresentationStyle = .Popover
//        photoCommentsViewController?.modalTransitionStyle = .CoverVertical
//        photoCommentsViewController?.photoID = photoID
//        photoCommentsViewController?.popoverPresentationController?.delegate = self
//        presentViewController(photoCommentsViewController!, animated: true, completion: nil)
    }
    
    // Needed for the Comments Popover
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverCurrentContext
    }
    
    // Needed for the Comments Popover
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        
        return navController
    }
    
    func barButtonItemWithImageNamed(imageName: String?, title: String?, action: Selector? = nil) -> UIBarButtonItem {
        let button = UIButton(type: .Custom)
        
        if imageName != nil {
            button.setImage(UIImage(named: imageName!)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        
        if title != nil {
            button.setTitle(title, forState: .Normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
            
            let font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            button.titleLabel?.font = font
        }
        
        let size = button.sizeThatFits(CGSize(width: 90.0, height: 30.0))
        button.frame.size = CGSize(width: min(size.width + 10.0, 60), height: size.height)
        
        if action != nil {
            button.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
        }
        
        let barButton = UIBarButtonItem(customView: button)
        
        return barButton
    }
    
    // MARK: Gesture Recognizers
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer!) {
        let pointInView = recognizer.locationInView(self.imageView)
        self.zoomInZoomOut(pointInView)
    }
    
    // MARK: ScrollView
    
    func centerFrameFromImage(image: UIImage?) -> CGRect {
        if image == nil {
            return CGRectZero
        }
        
        let scaleFactor = scrollView.frame.size.width / image!.size.width
        let newHeight = image!.size.height * scaleFactor
        
        var newImageSize = CGSize(width: scrollView.frame.size.width, height: newHeight)
        
        newImageSize.height = min(scrollView.frame.size.height, newImageSize.height)
        
        let centerFrame = CGRect(x: 0.0, y: scrollView.frame.size.height/2 - newImageSize.height/2, width: newImageSize.width, height: newImageSize.height)
        
        return centerFrame
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.frame
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentsFrame
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func zoomInZoomOut(point: CGPoint!) {
        let newZoomScale = self.scrollView.zoomScale > (self.scrollView.maximumZoomScale/2) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale
        
        let scrollViewSize = self.scrollView.bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = point.x - (width / 2.0)
        let y = point.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
        
        self.scrollView.zoomToRect(rectToZoom, animated: true)
    }
}
