//
//  TabBarViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit

//16進数color 機能拡張
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
}

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        //tabbarの色を変更
        tabBar.barTintColor = UIColor(hex: "ffffff")
    
        //tabbar背景の透過
        UITabBar.appearance().backgroundImage = UIImage()
    
        //tabbarの選択色の設定
        tabBar.tintColor = UIColor(hex: "2DCCD3")
    
        //tabbarの非選択色の設定
        tabBar.unselectedItemTintColor =  UIColor.gray
    }
    
    //tabbarをタップした場合のアクション
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "ニュース":
            print("タップするとTOPにスクロールして欲しい")
        case "天気":
            print("アクション未定")
        case "検索":
            print("アクション未定")
        default:
            break
        }
    }
}
