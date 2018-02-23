//
//  BarView.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/8/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
enum ScrollDirection {
    case right
    case left
}
class BarView: UIView {
    let iconViewWidth:CGFloat = 50.0
    typealias Listener = (ScrollDirection)->()
    var listeners = [Listener]()
    var scrollView:UIScrollView!
    var label:UILabel!
    var titleViews = [UIView]()
    var iconViews = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createScrollView(frame: self.bounds)
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createScrollView(frame: self.bounds)
    }
    
    func addItem(iconView:UIView) {

        iconViews.append(iconView)
        iconView.center = scrollView.center
        scrollView.addSubview(iconView)
        scrollView.contentOffset = CGPoint(x:0, y: 0)
        
        let iconViewsCount = iconViews.count
        let screenHalf = scrollView.frame.size.width / 2
        let interItemDistance = screenHalf - iconViewWidth / 2 - 5
        iconViews.first?.center.x = screenHalf
        for i in 1..<iconViews.count{
            iconViews[i].center.x = interItemDistance * CGFloat(i) + screenHalf
        }
        
        if iconViews.count == 1{
           scrollView.contentSize.width = 2 * screenHalf
        }else{
            scrollView.contentSize.width = screenHalf + interItemDistance * CGFloat(iconViewsCount) + iconViewWidth / 2 + 5
            scrollView.contentOffset = CGPoint(x: scrollView.center.x - iconViewWidth / 2 - 5, y: scrollView.contentOffset.y)
        }
        
        
        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(_:))))
        
        
        
        //call this to make all view sizes ready for scroll position 0
//        scrollView.delegate?.scrollViewDidScroll?(scrollView)
        
    }
    
    func addItemWith(TitleView titleView:UIView, iconView:UIView) {
        titleViews.append(titleView)
        iconViews.append(iconView)
        let titleViewsCount = titleViews.count
        let screenHalf = scrollView.frame.size.width / 2
        scrollView.contentSize.width = screenHalf + screenHalf * CGFloat(titleViewsCount) - titleView.frame.size.width / 2 - 5
        if titleViewsCount == 1{
            titleView.center = scrollView.center
            iconView.center = scrollView.center
        }else{
            let x = CGFloat(titleViewsCount) * screenHalf - titleView.frame.size.width / 2 - 5
            titleView.center = CGPoint(x: x, y: scrollView.center.y)
            iconView.center = CGPoint(x:x, y:scrollView.center.y)
        }
        
        scrollView.addSubview(titleView)
        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(_:))))
        
        scrollView.addSubview(iconView)
        
        if titleViewsCount == 1{
            
            titleView.alpha = 1
            iconView.alpha = 0
        }else{
            iconView.alpha = 1
            titleView.alpha = 0
            
        }
        
        //call this to make all view sizes ready for scroll position 0
        scrollView.delegate?.scrollViewDidScroll?(scrollView)
        
    }
    
    @objc func iconTapped(_ sender:UITapGestureRecognizer){
        let iconCenter = CGPoint(x: sender.view?.center.x ?? 0, y: sender.view?.center.y ?? 0)
        if (scrollView.center.x - iconCenter.x + scrollView.contentOffset.x) == 0{
            return
        }
        let direction = (scrollView.center.x - iconCenter.x + scrollView.contentOffset.x) < 0 ? ScrollDirection.right : ScrollDirection.left
        var newContentOffset = scrollView.contentOffset
        if direction == .right{
            newContentOffset.x += scrollView.center.x - 30
        }else{
            newContentOffset.x -= scrollView.center.x - 30
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.scrollView.contentOffset = newContentOffset
        }, completion: nil)
        
        
        for lis in listeners{
            lis(direction)
        }
    }
    
    func observeChange(listener:@escaping Listener) {
        listeners.append(listener)
    }
    
    func createScrollView(frame:CGRect) {
        
        
        let size = CGSize(width: UIScreen.main.bounds.size.width, height: frame.size.height)
        scrollView = UIScrollView(frame: CGRect(origin: CGPoint(x:0, y:0), size: size))
        scrollView.contentSize = CGSize(width: size.width, height: size.height)
        scrollView.backgroundColor = UIColor.clear
//        label = UILabel()
//        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
//        label.text = "Some custom text"
//        label.textAlignment = .center
//        //label.backgroundColor = UIColor.yellow
//        label.center = scrollView.center
//        scrollView.addSubview(label)
        scrollView.delegate = self
        //scrollView.backgroundColor = UIColor.yellow
//        let bottomLine = UIView(frame: CGRect(x: 0, y: bounds.size.height - 1, width: UIScreen.main.bounds.size.width, height: 1))
//        bottomLine.backgroundColor = UIColor.lightGray
//        addSubview(bottomLine)
        addSubview(scrollView)
        //bringSubview(toFront: scrollView)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension BarView:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        for view in titleViews{
//            let calculatedX = view.center.x - scrollView.contentOffset.x
//            let d = fabs(center.x - calculatedX)
//            let alpha = 1 - d / center.x
//            view.alpha = alpha
//            let transform = CGAffineTransform(scaleX: alpha, y: alpha)
//            view.transform = transform
//        }
        
        
        for view in iconViews{
            let calculatedX = view.center.x - scrollView.contentOffset.x
            let d = fabs(center.x - calculatedX)
            //let alpha = d / center.x
            let scale = 1 - d / center.x
            view.tintColor = UIColor(hue: 224 / 360, saturation: alpha, brightness: 0.73, alpha: 1.0)
            let transform = CGAffineTransform(scaleX: max(scale, 0.8), y: max(scale, 0.8))
            view.transform = transform
        }
        
    }
}
