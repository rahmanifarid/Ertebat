//
//  TextPostCollectionViewCell.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/13/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class TextPostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textView:UILabel!
    @IBOutlet weak var imageView:UIImageView!
    var postsVC:PostsViewController?
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func configure() {
        layer.cornerRadius = 10
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
//        imageView.layer.shadowColor = UIColor.lightGray.cgColor
//
//        imageView.layer.shadowOffset = CGSize(width:-5, height: -2)
//        imageView.layer.shadowRadius = 5
//        imageView.layer.shadowOpacity = 0.9
        let gestureRec = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(gestureRec)
        imageView.isUserInteractionEnabled = true
        
    }
    @objc func imageTapped(_ sender:UITapGestureRecognizer){
        print("Tapped")
        postsVC?.zoomImageView(sender.view as! UIImageView)
    }
    
    override func prepareForReuse() {
        textView.text = nil
        imageView.image = nil
        imageView.isHidden = false
    }
}
