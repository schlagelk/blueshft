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
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        if userButton != nil {
            userButton?.enabled = false
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setRecentLikeLabel()
        setGreetingLabel()
        self.containerView.addBottomBorderWithColor(UIColor.blackColor(), width: 0.75)
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
                                self.recentLikeLabel.text = like["name"] as? String
                                self.likeImage.image = self.likeImage.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                                self.likeImage.tintColor = UIColor.blueshftBlue()
                            }
                        }
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
            if let dateCreated = user.createdAt {
                dateFormatter.dateStyle = .LongStyle
                joinedLabel.text = "Joined: \(dateFormatter.stringFromDate(dateCreated))"
            }
            emailLabel.text = user.email
        } else {
            greetingLabel.text = "Hello, there!"
        }
    }
    
}
