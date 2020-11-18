//
//  TabBarViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //起動時のitemの色
        UITabBar.appearance().tintColor = UIColor(hex: "2DCCD3")
        
        //tabbarの色を変更
        tabBar.barTintColor = UIColor(hex: "ffffff")
    
        //tabbar背景の透過
        UITabBar.appearance().backgroundImage = UIImage()
    }
    
    //tabbarをタップした場合のアクション
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "ニュース":
            tabBar.tintColor = UIColor(hex: "2DCCD3")
        case "天気":
            tabBar.tintColor = UIColor(hex: "ff4500")
        case "アカウント":
            tabBar.tintColor = UIColor(hex: "ffa500")
        default:
            //tabbarの非選択色の設定
            tabBar.unselectedItemTintColor =  UIColor.gray
        }
    }
}
