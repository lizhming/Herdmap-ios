//
//  CustomReviewCell.swift
//  MyApp6
//
//  Created by Muhammad Bilal on 18/09/2017.
//  Copyright © 2017 Muhammad Bilal. All rights reserved.
//

import UIKit
import Cosmos

class CustomReviewCell: UITableViewCell {

    
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var myRating: CosmosView!
    @IBOutlet weak var myDetails: UILabel!
    
    @IBOutlet weak var myImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
