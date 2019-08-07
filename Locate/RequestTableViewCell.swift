//
//  RequestTableViewCell.swift
//  Locate
//
//  Created by Paul Ter on 8/6/19.
//  Copyright © 2019 Paul Ter. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.cornerRadius = self.profilePic.frame.width / 2
    }

    @IBAction func acceptPressed(_ sender: Any) {
        print("accepted")
    }
    
    @IBAction func denyPressed(_ sender: Any) {
        print("denied")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
