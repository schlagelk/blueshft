//
//  MasterViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/26/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit
import CoreData

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
            query?.whereKey("name", containsString: searchBar.text)
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
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
}

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
        self.loadObjects()    }
}