//
//  FriendSearchTableViewCell.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 24/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit

class FriendSearchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var myTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
