//
//  TableViewCell.swift
//  Ertebat
//
//  Created by Farid Rahmani on 1/30/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var postText: UITextView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var profilePictureView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postText.layer.cornerRadius = 3
        profilePictureView.layer.cornerRadius = 32
        profilePictureView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
