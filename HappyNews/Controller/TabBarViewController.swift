//
//  TabBarViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    //TabBar呼び出し
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTab()
    }
}
    
    //TabBarの作成
    private extension MainTabBarController {
        func setupTab() {
            
            //NewsViewControllerのインスタンスを作成
            let newsViewController = NewsViewController()
            
            //NewsViewControllerのTabBarのアイテムを設定
            newsViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 0)
            
            //SearchViewControllerのインスタンスを作成
            let searchViewController = SearchViewController()
            
            //SearchViewControllerのTabBarのアイテムを設定
            searchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
            
            viewControllers = [newsViewController, searchViewController]
        }
    }
