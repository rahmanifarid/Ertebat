//
//  TabBarSegue.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/8/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class TabBarSegue: UIStoryboardSegue {
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        if let customTabBar = source as? CustomTabBar{
            customTabBar.add(Tab: destination)
            print("source was custom tab bar")
        }
        print("We are out of if now")
    }
    
    override func perform() {
        print("perform called")
    }
    
    
}
