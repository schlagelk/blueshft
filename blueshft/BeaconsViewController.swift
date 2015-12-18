//
//  BeaconsViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 12/15/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class BeaconsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedCellIndexPath: NSIndexPath?
    let SelectedCellHeight: CGFloat = 140
    let UnselectedCellHeight: CGFloat = 80.0
    
    var beacons = [Beacon]() {
        didSet {
            print(self.beacons)
            // maybe beginUpdates & endUpdates for table here?
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataForBeacons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beacons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "BeaconsTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BeaconsTableViewCell
        let beaconOnCell = beacons[indexPath.row]
        cell.beaconNameLabel.text = beaconOnCell.name
        cell.beaconDescLabel.text = beaconOnCell.subTitle
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedCellIndexPath = selectedCellIndexPath {
            if selectedCellIndexPath == indexPath {
                self.selectedCellIndexPath = nil
            } else {
                self.selectedCellIndexPath = indexPath
            }
        } else {
            selectedCellIndexPath = indexPath
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let selectedCellIndexPath = selectedCellIndexPath {
            if selectedCellIndexPath == indexPath {
                return SelectedCellHeight
            }
        }
        return UnselectedCellHeight
    }
    
    func loadDataForBeacons() {
        let query = Beacon.query()
        query!.whereKey("minor", equalTo: "8U8j3o7u7T")
        query!.whereKey("major", equalTo: "123")
        do {
            let objects = try query!.findObjects() as! [Beacon]
            self.beacons.appendContentsOf(objects)
        } catch {
            print(error)
        }
    }
}