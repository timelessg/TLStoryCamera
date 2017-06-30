//
//  FirstViewController.swift
//  TLStoryCamera
//
//  Created by garry on 2017/5/27.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    let scrollView = UIScrollView()
    let pageVc = FirstSubViewController()
    let storyVc = TLStoryViewController()
    
    var lastPage:Int = 0
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = view.bounds
        scrollView.backgroundColor = UIColor.white
        scrollView.contentSize = CGSize(width: screenWidth * 2, height: 0)
        scrollView.contentOffset = CGPoint(x: screenWidth, y: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        
        storyVc.view.frame = CGRect.init(x: 0, y: -44, width: screenWidth, height: screenHeight)
        storyVc.delegate = self
        scrollView.addSubview(storyVc.view)
        self.addChildViewController(storyVc)
        
        pageVc.view.frame = CGRect.init(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
        scrollView.addSubview(pageVc.view)
        self.addChildViewController(pageVc)
        
        self.view.addSubview(scrollView)
        
        lastPage = 1
        
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            let offsetX = scrollView.contentOffset.x
            
            if offsetX < screenWidth {
                self.tabBarController?.tabBar.transform = CGAffineTransform(translationX: screenWidth - offsetX, y: 0)
                self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: screenWidth - offsetX, y: 0)
            } else {
                self.tabBarController?.tabBar.transform = CGAffineTransform.identity
                self.navigationController?.navigationBar.transform = CGAffineTransform.identity
            }            
        }
    }
}

extension FirstViewController:TLStoryViewDelegate {
    func storyViewClose() {
        self.scrollView.contentOffset = CGPoint.init(x: self.view.width, y: 0)
        self.lastPage = 1
        self.storyVc.resumeCamera(open: false)
    }
    
    func storyViewRecording(running complete: Bool) {
        self.scrollView.isScrollEnabled = !complete
    }

    func storyViewDidPublish(type: TLStoryType, url: URL?) {
        guard let u = url else {
            return
        }
        print("\(type)-----\(u)")
    }
}

extension FirstViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / screenWidth);
        if (self.lastPage == page) {
            return;
        }
        self.lastPage = page;
        self.storyVc.resumeCamera(open: page == 0)
    }
}
