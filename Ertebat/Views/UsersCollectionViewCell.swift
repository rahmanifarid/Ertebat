//
//  UsersCollectionViewCell.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/1/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
class UsersCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    var userId:String!
    
    
    
    override func prepareForReuse() {
        imageView.image = UIImage(named:"placeholder-profile")
        
    }
    var imageObserver:NSKeyValueObservation?
    var nameObservation:NSKeyValueObservation?
    var user:User?
    func setData(_ user:User){
        self.user = user
        imageObserver = user.observe((\.profileImage)) { (changedUser, change) in
            self.imageView.alpha = 0
            self.imageView.image = changedUser.profileImage
            UIView.animate(withDuration: 0.5, animations: {
                self.imageView.alpha = 1.0
            })
        }
        nameObservation = user.observe((\.name), changeHandler: { (changedUser, change) in
            self.nameLabel.alpha = 0
            self.nameLabel.text = user.name
            if user.id == Auth.auth().currentUser?.uid, let name = user.name{
                self.nameLabel.text = name + " " + "(You)"
            }
            UIView.animate(withDuration: 0.5, animations: {
                self.nameLabel.alpha = 1.0
            })
        })
        nameLabel.text = user.name
        if user.id == Auth.auth().currentUser?.uid, let name = user.name{
            self.nameLabel.text = name + " " + "(You)"
        }
        imageView.image = user.profileImage
        user.startObservering()
    }
    
    func removeObservations() {
        imageObserver?.invalidate()
        nameObservation?.invalidate()
        user?.stopObserving()
        user = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
    }
}
