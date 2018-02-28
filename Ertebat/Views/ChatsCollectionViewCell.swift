//
//  ChatsCollectionViewCell.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/9/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class ChatsCollectionViewCell: UICollectionViewCell {
    
    private var cellData:ChatsCellData?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var badgeLabel: UILabel!
    
    override func prepareForReuse() {
        imageView.image = nil
        observation?.invalidate()
        cellData = nil
        badgeLabel.text = nil
        badgeLabel.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 32
    }
    var observation:NSKeyValueObservation?
    var observationProfilePic:NSKeyValueObservation?
    var observationNumOfUnseenMsgs:NSKeyValueObservation?
    func setCellDataModel(_ cellData:ChatsCellData) {
        self.cellData = cellData
        updateUI()
        observation = self.cellData?.observe((\.downloaded), options: .new, changeHandler: { (data, change) in
            self.updateUI()
        })
        observationProfilePic = self.cellData?.observe((\.profilePicPercent), options: .new, changeHandler: { (data, change) in
            if self.cellData?.profilePicPercent == 100{
                self.imageView.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                    self.imageView.image = self.cellData?.profilePic
                    UIView.animate(withDuration: 0.3, animations: {
                        self.imageView.alpha = 1.0
                    })
                })
                
            }
        })
        
        observationNumOfUnseenMsgs = self.cellData?.observe((\.unseenMessages), changeHandler: { (data, change) in
            
            if data.unseenMessages > 0{
                self.badgeLabel.text = String(data.unseenMessages)
                self.badgeLabel.isHidden = false
            }else{
                self.badgeLabel.isHidden = true
            }
        })
        
        
        
    }
    
    
    
    func updateUI() {
        print("update ui called")
        if self.cellData?.downloaded == true{
            titleLabel.text = self.cellData?.user.name
            messageLabel.text = self.cellData?.lastMessage.text
            imageView.image = cellData?.profilePic
        }
    }
}
