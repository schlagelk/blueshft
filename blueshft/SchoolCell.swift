//
//  SchoolCell.swift
//  blueshft
//
//  Created by Kenny Schlagel on 9/27/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class SchoolCell: PFTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var enrollmentLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var schoolImage: PFImageView!
}
