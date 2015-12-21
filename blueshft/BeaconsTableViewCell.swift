//
//  BeaconsTableViewCell.swift
//  blueshft
//
//  Created by Kenny Schlagel on 12/17/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class BeaconsTableViewCell: UITableViewCell {

    @IBOutlet weak var beaconNameLabel: UILabel!
    @IBOutlet weak var beaconDescLabel: UILabel!
    
    @IBOutlet weak var beaconImage: PFImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
