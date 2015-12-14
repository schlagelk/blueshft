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
    
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    let scrollView = UIScrollView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    // add init?
    var photoInfo: Photo?
    var image: PFFile?
    var pointName: String?
    var likeCountForUser: Int?
    
    var myToolbar: UIToolbar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupView()
        loadPhoto()
        self.descLabel.text = self.photoInfo?.text
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
        labelContainer.layer.cornerRadius = 10
        scrollView.addSubview(labelContainer)

        labelContainer.addSubview(descLabel)
        
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
        self.myToolbar.items = nil
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        items.append(barButtonItemWithImageNamed("back", title: nil, action: "goBack"))
        
        items.append(flexibleSpace)
        let barButt = UIBarButtonItem(title: self.pointName, style: .Plain, target:nil, action:nil)
        items.append(barButt)
        items.append(flexibleSpace)
        
        getLikesForUser()
        var likes = photoInfo?.likes ?? 0
        
        if self.likeCountForUser > 0 {
            let likesToView = String(likes)
            items.append(barButtonItemWithImageNamed("unlike", title: likesToView, action: "unlike", tint: true))

        } else {
            let likesToView = String(likes)
            items.append(barButtonItemWithImageNamed("like", title: likesToView, action: "like"))
        }

        self.myToolbar.frame = CGRectMake(0, self.view.frame.height - 44, self.view.frame.size.width, 44)
        self.myToolbar.items = items
        self.myToolbar.barTintColor = UIColor.blackColor()
        self.myToolbar.opaque = false
        self.view.addSubview(self.myToolbar)
    }
    
    func getLikesForUser() {
        if let objId = self.photoInfo?.objectId {
            let user = PFUser.currentUser()
            let className = "Like"
            let query = PFQuery(className: className)
            query.whereKey("objetoId", equalTo: objId)
            query.whereKey("userId", equalTo: (user?.objectId)!)
            
            let err: NSErrorPointer = nil
            self.likeCountForUser = query.countObjects(err)

        } else {
            print("no object id")
        }
    }
    
    func like() {
        if let objId = self.photoInfo?.objectId {
            let user = PFUser.currentUser()
            
            let post = PFObject(className: "Like")
            post["object"] = "photo"
            post["user"] = user
            post["objetoId"] = objId
            post["userId"] = user?.objectId
            post["name"] = self.pointName
            
            do {
                try post.save()
                var likes = self.photoInfo!.likes
                ++likes
                self.photoInfo?.likes = likes
                try self.photoInfo!.save()
                removeUnlikeToolbarButtonAndAddLike(likes)
            } catch {
                print(error)
            }
        } else {
                print("no object id")
        }
    }
    
    func removeUnlikeToolbarButtonAndAddLike(likes: Int) {
        self.myToolbar.items?.removeLast()
        let butt = barButtonItemWithImageNamed("unlike", title: String(likes), action: "unlike", tint: true)
        self.myToolbar.items?.append(butt)
    }
    
    func unlike() {
        if let objId = self.photoInfo?.objectId {
            let user = PFUser.currentUser()
            let query = PFQuery(className: "Like")
            //fetch count
            query.whereKey("objetoId", equalTo: objId)
            query.whereKey("userId", equalTo: (user?.objectId)!)
            do {
                let objs = try query.findObjects()
                for object in objs {
                    object.deleteInBackground()
                }
                //update main object likes
                var likes = self.photoInfo!.likes
                --likes
                self.photoInfo?.likes = likes
                try self.photoInfo!.save()
                removeLikeToolbarButtonAndAddUnlike(likes)
            } catch {
                print (error)
            }
        } else {
            print("no object id")
        }
    }
    
    func removeLikeToolbarButtonAndAddUnlike(likes: Int) {
        self.myToolbar.items?.removeLast()
        let butt = barButtonItemWithImageNamed("like", title: String(likes), action: "like")
        self.myToolbar.items?.append(butt)
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
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake { self.labelContainer.hidden = !self.labelContainer.hidden }
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
    
    func barButtonItemWithImageNamed(imageName: String?, title: String?, action: Selector? = nil, tint: Bool? = false) -> UIBarButtonItem {
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
        
        if tint == true {
            button.tintColor = UIColor(red: 232/255, green: 104/255, blue: 87/255, alpha: 1)
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
