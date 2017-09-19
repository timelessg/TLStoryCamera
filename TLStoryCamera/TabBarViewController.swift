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
        
        let fristVc = FirstViewController.init()
        fristVc.title = "One"
        fristVc.view.backgroundColor = UIColor.black
        let fristNav = UINavigationController.init(rootViewController: fristVc)
        
        let secondVc = UIViewController.init()
        secondVc.title = "Two"
        secondVc.view.backgroundColor = UIColor.gray
        let secondNav = UINavigationController.init(rootViewController: secondVc)
        
        self.viewControllers = [fristNav,secondNav]
        
    }
}
