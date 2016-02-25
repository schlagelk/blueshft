//
//  BeaconsViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 12/15/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class BeaconsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerInfoView: UIView!
    @IBOutlet weak var beaconInfoImage: UIImageView!
    
    var selectedCellIndexPath: NSIndexPath?
    let SelectedCellHeight: CGFloat = 220
    let UnselectedCellHeight: CGFloat = 80.0
    
    weak var locationManager: CLLocationManager?
    var region: CLBeaconRegion?
    
    weak var detailVC: DetailViewController?
    
    var beacons4School = [Beacon]() {
        didSet {
            // maybe beginUpdates & endUpdates for table here?
            tableView.reloadData()
        }
    }
  
  var timer = 1
        
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadDataForBeacons()
        containerInfoView.addTopBorderWithColor(UIColor.grayColor(), width: 0.8)
        let beacmage = UIImage(named:"beacon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        beaconInfoImage.image = beacmage
        if self.locationManager != nil && self.region != nil {
            self.locationManager?.delegate = self
            self.locationManager!.startRangingBeaconsInRegion(self.region!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if self.locationManager != nil && self.region != nil {
            self.locationManager?.stopMonitoringForRegion(self.region!)
            self.locationManager?.delegate = detailVC
            self.region = nil
        }
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
        return self.beacons4School.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "BeaconsTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BeaconsTableViewCell
        let beaconOnCell = beacons4School[indexPath.row]
        cell.beaconNameLabel.text = beaconOnCell.name
        cell.beaconDescLabel.text = beaconOnCell.subTitle
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! BeaconsTableViewCell
        currentCell.beaconImage.hidden = false
        let beaconOnCell = beacons4School[indexPath.row]
        
        if let selectedCellIndexPath = selectedCellIndexPath {
            if selectedCellIndexPath == indexPath {
                self.selectedCellIndexPath = nil
                currentCell.beaconImage.hidden = true
            } else {
                self.selectedCellIndexPath = indexPath
            }
        } else {
            selectedCellIndexPath = indexPath
        }
        
        currentCell.beaconImage.file = beaconOnCell.image
        currentCell.beaconImage.loadInBackground {(image: UIImage?, error: NSError?) ->Void in
            if error == nil {
                if let leImage = image {
                    currentCell.beaconImage.image = leImage
                }
            } else {
                print("problem loading image \(error)")
            }
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
    
    //MARK: Beacons
    
    func loadDataForBeacons(major: String) {

        let query = Beacon.query()
        query!.whereKey("major", equalTo: major)
        // TODO - need to specify a minor value?
        do {
            let objects = try query!.findObjects() as! [Beacon]
            self.beacons4School.removeAll()
            self.beacons4School.appendContentsOf(objects)
        } catch {
            print(error)
        }
    }
    
    
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
      timer++
      if timer % 3 == 0 {
        let knownBeacons = beacons.filter { $0.proximity != CLProximity.Unknown }
        if knownBeacons.count > 0 {
          self.beacons4School.removeAll()
          // get data for each beacon, append to data source if succesful
          var query = Beacon.query()
          for beacon in knownBeacons {
            query?.whereKey("major", equalTo: beacon.major.stringValue)
            query?.whereKey("minor", equalTo: beacon.minor.stringValue)
            query?.limit = 1
            
            do {
              let objects = try query?.findObjects() as! [Beacon]
              if objects.first != nil {
                self.beacons4School.append(objects.first!)
              }
            } catch {
              print(error)
            }
          }
          UIView.transitionWithView(tableView, duration: 0.10, options: .TransitionCrossDissolve, animations: {
            self.tableView.reloadData()
            }, completion: nil)
        }
      }
    }
}