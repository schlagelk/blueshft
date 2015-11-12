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

class OverlayViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
//    @IBAction func closeButtonPressed(sender: AnyObject) {
//        presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    var point: Point?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        
        let query = Thumbnail.query()
        let parentId: String = "dcEbZ8pUqv"
        query!.whereKey("parentId", equalTo: parentId)
        
        query!.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if objects as? [Thumbnail] != nil {
                    for imageObjects in objects! {
                        if let castedImageObject = imageObjects as? Thumbnail {
                            self.photos.addObject(castedImageObject)
                        }
                    }
                    self.collectionView!.reloadData()
                }
            } else {
                print("error: \(error)")
            }
        }
    }
    
    var photos = NSMutableOrderedSet()
    
    let imageCache = NSCache()
    
    let refreshControl = UIRefreshControl()
    
    var populatingPhotos = false
    var currentPage = 1
    
    let PhotoBrowserCellIdentifier = "PhotoBrowserCell"
    let PhotoBrowserFooterViewIdentifier = "PhotoBrowserFooterView"
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showDirections" {
//            if let destinationVC = segue.destinationViewController as? DetailViewController {
//                destinationVC.getDirectionsToPoint(point!)
//            }
//        }
//    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoBrowserCellIdentifier, forIndexPath: indexPath) as! PhotoBrowserCollectionViewCell
//        
//        cell.imageView.image = nil
//        
//        //MARK: get photos from PARSE
        let image = photos.objectAtIndex(indexPath.row) as! Thumbnail
        cell.imageView.image = UIImage(named: "2")
        cell.imageView.file = image.thumbnail
        cell.imageView.loadInBackground()
        return cell
    }
    
    // Used to display a spinner at the bottom when we're waiting to load more photos
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoBrowserFooterViewIdentifier, forIndexPath: indexPath) 
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        performSegueWithIdentifier("ShowPhoto", sender: (self.photos.objectAtIndex(indexPath.item) as! PhotoInfo).id)
    }
    
    // MARK: Helper
    
    func setupView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Using a standard UICollectionViewFlowLayout, displaying 3 cells in each row
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (view.bounds.size.width - 2) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 100.0)
        
        collectionView!.collectionViewLayout = layout
        
        navigationItem.title = "Featured"
        
        collectionView!.registerClass(PhotoBrowserCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoBrowserCellIdentifier)
        collectionView!.registerClass(PhotoBrowserCollectionViewLoadingCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoBrowserFooterViewIdentifier)
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ShowPhoto" {
//            (segue.destinationViewController as! PhotoViewerViewController).photoID = sender!.integerValue
//            (segue.destinationViewController as! PhotoViewerViewController).hidesBottomBarWhenPushed = true
//        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        // Populate more photos when the scrollbar indicator is at 80%
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            populatePhotos()
        }
    }
    
    func populatePhotos() {
//        if populatingPhotos { // Do not populate more photos if we're in the process of loading a page
//            return
//        }
//        
//        populatingPhotos = true
//        //MARK: get photos from PARSE
//        let query = Image.query()
//        let parentId: String = "dcEbZ8pUqv"
//        query!.whereKey("parentId", equalTo: parentId)
//
//        query!.findObjectsInBackgroundWithBlock { (objects, error) in
//            if error == nil {
//                if objects as? [Image] != nil {
//                    for imageObjects in objects! {
//                        if let castedImageObject = imageObjects as? Image {
//                            let image = castedImageObject.thumbnail
//                            print("col obj: \(castedImageObject)")
//                            image.getDataInBackgroundWithBlock {
//                                (imageData: NSData?, error: NSError?) -> Void in
//                                if error == nil {
//                                    if let imageData = imageData {
//                                        let lastItem = self.photos.count
//                                        self.photos.addObject(imageData)
//                                        let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
//                                        self.collectionView!.insertItemsAtIndexPaths(indexPaths)
//                                        self.currentPage++
//                                    }
//                                } else {
//                                    print("something happened while downloading thumbs")
//                                }
//                            }
//                            self.populatingPhotos = false
//                        }
//                    }
//                }
//            } else {
//                print("error: \(error)")
//            }
//        }


    }
    
    func handleRefresh() {
        refreshControl.beginRefreshing()
        
        // Reset the model
        self.photos.removeAllObjects()
        self.currentPage = 1
        
        // Refresh the UI
        self.collectionView!.reloadData()
        
        // We have our own spinner
        refreshControl.endRefreshing()
        
        populatePhotos()
    }
}

class PhotoBrowserCollectionViewCell: UICollectionViewCell {

    let imageView = PFImageView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        imageView.frame = bounds
        addSubview(imageView)
    }
}

class PhotoBrowserCollectionViewLoadingCell: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spinner.startAnimating()
        spinner.center = self.center
        addSubview(spinner)
    }
}
