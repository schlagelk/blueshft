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
    
    var beacons = [Point]() {
        didSet {

        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.beacons)

        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
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
        cell.beaconDescLabel.text = beaconOnCell.details
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected beacon #\(indexPath.row)!")
    }
}
