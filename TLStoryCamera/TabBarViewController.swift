//
//  TabBarViewController.swift
//  TLStoryCamera
//
//  Created by garry on 2017/5/27.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fristVc = FristViewController.init()
        fristVc.title = "One"
        fristVc.view.backgroundColor = UIColor.gray
        let fristNav = UINavigationController.init(rootViewController: fristVc)
        
        let secondVc = UIViewController.init()
        secondVc.title = "Two"
        secondVc.view.backgroundColor = UIColor.purple
        let secondNav = UINavigationController.init(rootViewController: secondVc)
        
        self.viewControllers = [fristNav,secondNav]
        
    }
}
