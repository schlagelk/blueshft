//
//  PopupViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 12/6/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {
    
    @IBOutlet weak var recentLikeLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    weak var userButton: UIBarButtonItem?

    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        if userButton != nil {
            userButton?.enabled = false
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setRecentLikeLabel()
        setGreetingLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setRecentLikeLabel() {
        if let user = PFUser.currentUser() {
            let className = "Like"
            let query = PFQuery(className: className)
            query.orderByDescending("createdAt")
            query.limit = 1
            
            query.findObjectsInBackgroundWithBlock { (likes, error) in
                if error == nil {
                    if likes != nil {
                        if let likes = likes {
                            for like in likes {
                                self.recentLikeLabel.text = like["name"] as! String
                            }
                        }
                    } else {
                        self.recentLikeLabel.text = "You have no recent +'s"
                    }
                } else {
                    print("error: \(error)")
                }
            }
        }
    }
    
    func setGreetingLabel() {
        if let user = PFUser.currentUser() {
            greetingLabel.text = "Hello, " + user.username! + "!"
        } else {
            greetingLabel.text = "Hello, there!"
        }
    }
    
}
