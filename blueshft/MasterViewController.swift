//
//  MasterViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/26/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var schools = [School]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        loadSchools()
    }
    
    func loadSchools() {
        let query = PFQuery(className: "School")
        query.orderByDescending("createdAt")
        
        do {
            let objects = try query.findObjects()
            
            if objects.count == 0 {
                query.cachePolicy = PFCachePolicy.CacheThenNetwork
            }
            for school in objects {
                var locationString = school["city"] as! String
                locationString += ", "
                locationString += school["state"] as! String
                self.schools.append(School(name: school["name"] as! String, enrollment: school["students"] as! String, location: locationString))
            }
        } catch {
            print(error)
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        let alert = UIAlertController(title: "Not Implemented", message:
            "Can't create new schools yet maybe ever, will implement later",
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Segues

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = self.tableView.indexPathForSelectedRow {
//            let school = schools[indexPath.row]
//                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = school
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
//        }
//    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.schools.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let school = self.schools[indexPath.row]
        cell.textLabel?.text = school.name
        cell.detailTextLabel?.text = school.location
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

}

