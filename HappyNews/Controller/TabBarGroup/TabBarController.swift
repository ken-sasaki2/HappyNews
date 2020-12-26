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
        UITabBar.appearance().tintColor = UIColor(hex: "00AECC")
        
        //tabbarの色を変更
        tabBar.barTintColor = UIColor(hex: "ffffff")
        
        //tabbar背景の透過
        UITabBar.appearance().backgroundImage = UIImage()
    }
    
    //tabbarをタップした場合のアクション
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "ニュース":
            tabBar.tintColor = UIColor(hex: "00AECC")
        case "アカウント":
            tabBar.tintColor = UIColor(hex: "00AECC")
        default:
            //tabbarの非選択色の設定
            tabBar.unselectedItemTintColor =  UIColor.gray
        }
    }
}
