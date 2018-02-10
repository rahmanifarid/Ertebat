//
//  CustomNavigationBar.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/6/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var scrollView:UIScrollView!
    var label:UILabel!
    var titleViews = [UIView]()
    var rightBarItems = [UIView]()
    
    override init(frame: CGRect) {
        
        
        super.init(frame: frame)
        items = [UINavigationItem]()
        createScrollView(frame:frame)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createScrollView(frame: self.frame)
        
    }
    
    func createScrollView(frame:CGRect) {
       
        
        let size = CGSize(width: UIScreen.main.bounds.size.width, height: frame.size.height)
        scrollView = UIScrollView(frame: CGRect(origin: CGPoint(x:0, y:0), size: size))
        scrollView.contentSize = CGSize(width: 2 * size.width, height: size.height)
        scrollView.backgroundColor = UIColor.yellow
        label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        label.text = "Some custom text"
        label.textAlignment = .center
        //label.backgroundColor = UIColor.yellow
        label.center = scrollView.center
        scrollView.addSubview(label)
        scrollView.delegate = self
        //scrollView.backgroundColor = UIColor.yellow
        
        addSubview(scrollView)
        //bringSubview(toFront: scrollView)
    }
    
    override func popItem(animated: Bool) -> UINavigationItem? {
        return items?.popLast()
    }
    
    override func pushItem(_ item: UINavigationItem, animated: Bool) {
        //set the content size
        items?.append(item)
        let screenHalf = UIScreen.main.bounds.size.width / 2
        scrollView.contentSize.width = screenHalf + screenHalf * CGFloat(items?.count ?? 1)
        let x = CGFloat(items?.count ?? 1) * screenHalf
        
        if let titleView = item.titleView{
            titleView.frame = CGRect(origin: CGPoint(x: x, y: 0), size: titleView.frame.size)
            scrollView.addSubview(titleView)
            titleViews.append(titleView)
            if items!.count > 1{
                titleView.alpha = 0
            }
        }else{
            let label = UILabel()
            label.text = item.title
            label.textAlignment = .center
            label.textColor = UIColor.brown
            let labelSize = label.sizeThatFits(CGSize(width:320, height: 44))
            label.frame = CGRect(origin: CGPoint(x: x, y: 0), size: labelSize)
            scrollView.addSubview(label)
            titleViews.append(label)
            if items!.count > 1{
                label.alpha = 0
            }
        }
        
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        button.frame = CGRect(x: x, y: 0, width: 100, height: 44)
        rightBarItems.append(button)
        scrollView.addSubview(button)
        
        
        
        
    }
    
    @objc func backAction(_ sender:UIButton){
        delegate?.navigationBar?(self, didPop: items!.popLast()!)
    }

}

extension CustomNavigationBar:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = scrollView.center
        for view in titleViews{
            let calculatedX = view.center.x - scrollView.contentOffset.x
            let d = fabs(center.x - calculatedX)
            let alpha = 1 - d / center.x
            view.alpha = alpha
            let transform = CGAffineTransform(scaleX: alpha, y: alpha)
            view.transform = transform
        }
        
        for view in rightBarItems{
            let calculatedX = view.center.x - scrollView.contentOffset.x
            let d = fabs(center.x - calculatedX)
            let alpha = d / center.x
            view.alpha = alpha
            let transform = CGAffineTransform(scaleX: alpha, y: alpha)
            view.transform = transform
        }
        
    }
}
