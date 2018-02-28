//
//  BarViewItem.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/27/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class BarViewItem: UIView {
    var imageView = UIImageView()
    var badge = UILabel()
    var currentBadgeValue = 0{
        didSet{
            print("Current badge value set to \(currentBadgeValue)")
            if currentBadgeValue <= 0{
                badge.isHidden = true
                currentBadgeValue = 0
            }else{
                badge.text = currentBadgeValue < 100 ? String(currentBadgeValue) : "99+"
                var size = badge.sizeThatFits(CGSize(width: 200, height: 20))
                size.height += 4
                if currentBadgeValue < 10{
                    size.width = size.height
                }else{
                    size.width += 8
                }
                badge.frame.size = size
                badge.frame.origin.x = 50 - size.width + 5
                badge.layer.cornerRadius = size.height / 2
                badge.isHidden = false
            }
        }
    }
    convenience init(image:UIImage){
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.init(frame: frame)
        imageView.frame = frame
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = image
        badge.backgroundColor = UIColor.red
        badge.textColor = UIColor.white
        badge.frame = CGRect(x: 40, y: 0, width: 0, height: 0)
        badge.font = UIFont.systemFont(ofSize: 16)
        badge.textAlignment = .center
        badge.clipsToBounds = true
        
        addSubview(badge)
        currentBadgeValue = 1
    }
    
    func increaseBadgeValue(byValue:Int) {
        currentBadgeValue += byValue
    }
    
    func decreaseBadgeValue(byValue:Int) {
        currentBadgeValue -= byValue
    }
    
    func setBadgeValue(toValue:Int) {
        currentBadgeValue = toValue
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
