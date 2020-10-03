//
//  TabBarViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            print("0番のアイテムをタップしました")
        case 1:
            print("1番のアイテムをタップしました")
        case 2:
            print("2番のアイテムをタップしました")
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
