//
//  CustomNavController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/7/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class CustomNavController: UINavigationController {
    override var isNavigationBarHidden: Bool{
        set{
            super.isNavigationBarHidden = newValue
            topToolbar.isHidden = newValue
        }
        get{
            return super.isNavigationBarHidden
        }
    }
    
    let topToolbar:UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
        v.backgroundColor = UIColor.brown
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topToolbar)
        topToolbar.isHidden = isNavigationBarHidden
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.yellow
        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: true)
        let tabBarItem = viewController.tabBarItem
       
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
