//
//  FriendsTableViewCell.swift
//  FoodSocialMedia
//
//  Created by Zain Budhwani on 8/28/18.
//  Copyright © 2018 Zain Budhwani. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var friendsCellImageView: UIImageView!
    
    @IBOutlet weak var friendsCellNameLabel: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
