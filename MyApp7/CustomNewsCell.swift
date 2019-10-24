//
//  CustomNewsCell.swift
//  MyApp6
//
//  Created by Muhammad Bilal on 11/09/2017.
//  Copyright © 2017 Muhammad Bilal. All rights reserved.
//

import UIKit

class CustomNewsCell: UITableViewCell {

    @IBOutlet weak var myTitle: UILabel!
    @IBOutlet weak var myDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
