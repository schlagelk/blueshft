//
//  MasterViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/26/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore

class MasterViewController: PFQueryTableViewController {

    var detailViewController: DetailViewController? = nil
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        tableView.reloadData()
        searchBar.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        if (PFUser.currentUser() == nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(viewController, animated: true, completion: nil)
            })
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell? {
        let cellIdentifier = "SchoolCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? SchoolCell
        
        if cell == nil {
            cell = PFTableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier) as? SchoolCell
        }
        
        if let school = object as? School {
            cell?.schoolImage.file = school.image
            cell?.schoolImage.loadInBackground(nil) { percent in
                cell?.progressView.progress = Float(percent) * 0.01
//                print(percent)
            }
            cell?.nameLabel.text = school.name
            cell?.locationLabel.text = "\(school.city), \(school.state)"
            cell?.enrollmentLabel.text = "\(school.students) students"
        } else {
            // we didnt get anything back
        
        }
        return cell
    }
    
    override func queryForTable() -> PFQuery {
        let query = School.query()
        
        if searchBar.text != "" {
            query?.whereKey("name", containsString: searchBar.text?.toProper)
        }
        
        if self.objects!.count == 0 {
            query?.cachePolicy = .CacheThenNetwork
        }
        query?.orderByDescending("createdAt")
        self.paginationEnabled = true
        print("text; \(searchBar.text)")
        return query!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let school = objectAtIndexPath(indexPath) as! School
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = school
            }
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    // MARK: Table Cell Animation
    var preventAnimation = Set<NSIndexPath>()
    
    let TipInCellAnimatorStartTransform:CATransform3D = {
        let rotationDegrees: CGFloat = -15.0
        let rotationRadians: CGFloat = rotationDegrees * (CGFloat(M_PI)/180.0)
        let offset = CGPointMake(-20, -20)
        var startTransform = CATransform3DIdentity
        startTransform = CATransform3DRotate(CATransform3DIdentity, rotationRadians, 0.0, 0.0, 1.0)
        startTransform = CATransform3DTranslate(startTransform, offset.x, offset.y, 0.0)
        
        return startTransform
    }()
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !preventAnimation.contains(indexPath) {
            preventAnimation.insert(indexPath)
            self.animate(cell)
        }
    }
    
    func animate(cell: UITableViewCell) {
        let view = cell.contentView
        view.layer.transform = TipInCellAnimatorStartTransform
        view.layer.opacity = 0.8
        
        UIView.animateWithDuration(0.4) {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        }
    }
}

//MARK: Search Bar Delegate
extension MasterViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.loadObjects()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.loadObjects()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.loadObjects()
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.loadObjects()
    }
}

extension String {
    
    var toProper:String {
        var result = lowercaseString
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).capitalizedString)
        return result
    }
}