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
    var postData:Post?
    var observation:NSKeyValueObservation?
    func setPostData(_ post:Post) {
        postData = post
        textView.text = post.text
        if postData?.imageDownloaded == true{
            imageView.image = postData?.image
        }else{
            observation = postData?.observe((\.percentImageDownloaded), changeHandler: { (post, change) in
                print("Percent Downloaded\(post.percentImageDownloaded)")
                if post.percentImageDownloaded == 100{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.imageView.alpha = 0
                        self.imageView.image = post.image
                        UIView.animate(withDuration: 0.4, animations: {
                            self.imageView.alpha = 1.0
                        })
                        
                    })
                    
                }
            })
        }
    }
    
    override func prepareForReuse() {
        observation?.invalidate()
        postData = nil
        textView.text = nil
        imageView.image = nil
        imageView.isHidden = false
    }
}
