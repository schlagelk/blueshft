//
//  PopupViewController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 12/6/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
