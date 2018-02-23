//
//  UsersCollectionViewCell.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/1/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class UsersCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    var userId:String!
    
    
    
    override func prepareForReuse() {
        imageView.image = UIImage(named:"placeholder-profile")
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
    }
}
