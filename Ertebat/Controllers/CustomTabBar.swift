//
//  CustomTabBar.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/8/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class CustomTabBar: UIViewController {
    
    var tabs = [UIViewController]()
    private var bottomScrollView = UIScrollView()
    var navBarHeight:CGFloat = 64
    var isViewTransitionInteractive = true
    var customNavBar: BarView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        customNavBar = BarView(frame: CGRect(x: 0, y: 20, width: view.frame.size.width, height: navBarHeight))
        view.addSubview(customNavBar)
        bottomScrollView.delegate = self
        bottomScrollView.frame = view.bounds
        bottomScrollView.frame.origin.y = navBarHeight + 20
        bottomScrollView.frame.size.height -= navBarHeight + 20
        bottomScrollView.contentSize = CGSize(width: CGFloat(tabs.count) * UIScreen.main.bounds.size.width, height: bottomScrollView.bounds.size.height - navBarHeight)
        bottomScrollView.isPagingEnabled = true
        bottomScrollView.isDirectionalLockEnabled = true
        bottomScrollView.alwaysBounceVertical = false
        
        view.addSubview(bottomScrollView)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        
        
        let users = storyboard.instantiateViewController(withIdentifier: "users")
        let uIconView = UIImageView()
        uIconView.image = #imageLiteral(resourceName: "peopleIcon")
        uIconView.contentMode = .scaleAspectFill
        uIconView.clipsToBounds = true
        uIconView.frame.size = CGSize(width: 50, height: 50)
        customNavBar.addItem(iconView: uIconView)
        add(Tab: users)
        
        let posts = storyboard.instantiateViewController(withIdentifier: "postsViewController")
        add(Tab: posts)
        let pIconView = UIImageView()
        pIconView.image = #imageLiteral(resourceName: "globeIcon")
        pIconView.contentMode = .scaleAspectFill
        pIconView.clipsToBounds = true
        pIconView.frame.size = CGSize(width: 50, height: 50)
        customNavBar.addItem(iconView: pIconView)
        
        let chats = storyboard.instantiateViewController(withIdentifier: "chats")
        
        add(Tab: chats)
        let chatIconView = UIImageView()
        chatIconView.image = #imageLiteral(resourceName: "speechBubble")
        chatIconView.contentMode = .scaleAspectFill
        chatIconView.clipsToBounds = true
        chatIconView.frame.size = CGSize(width: 50, height: 50)
        customNavBar.addItem(iconView: chatIconView)
        
        bottomScrollView.contentOffset.x = bottomScrollView.frame.width
        
        
        customNavBar.observeChange { (direction) in
            var contentOffset = self.bottomScrollView.contentOffset
            if direction == .right{
                contentOffset.x += 2.0 * self.bottomScrollView.center.x
            }else{
                contentOffset.x -= 2.0 * self.bottomScrollView.center.x
            }
            self.isViewTransitionInteractive = false
            UIView.animate(withDuration: 0.3, animations: {
                
                })
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.bottomScrollView.contentOffset = contentOffset
            }, completion: { (finished) in
                self.isViewTransitionInteractive = true
            })
            
            
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func add(Tab tab:UIViewController) {
        print("Tab added")
        tabs.append(tab)
        self.addChildViewController(tab)
        let screenWidth = UIScreen.main.bounds.size.width
        bottomScrollView.contentSize.width += screenWidth
        tab.view.frame = bottomScrollView.bounds
        tab.view.frame.origin.x = screenWidth * CGFloat(tabs.count - 1)
        tab.willMove(toParentViewController: self)
        bottomScrollView.addSubview(tab.view)
        tab.didMove(toParentViewController: self)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CustomTabBar:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isViewTransitionInteractive {
            let a = scrollView.frame.size.width
            customNavBar.scrollView.contentOffset.x = (scrollView.contentOffset.x * (a - 60)) / (2 * a)
        }
    }
}
