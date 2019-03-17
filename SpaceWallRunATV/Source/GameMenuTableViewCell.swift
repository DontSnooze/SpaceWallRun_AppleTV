//
//  GameMenuTableViewCell.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/17/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import UIKit

class GameMenuTableViewCell: UITableViewCell {

    @IBOutlet var menuButton: UIButton?
    @IBOutlet var menuLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
