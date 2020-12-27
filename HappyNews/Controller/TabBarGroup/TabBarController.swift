//
//  TabBarViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        
            //ログインの有無でログインページの出す出さないを決める
            if Auth.auth().currentUser  == nil {
                
                //ログインページのインスタンスを作成しNavigationを継承
                let loginView = LoginViewController()
                let loginViewController = UINavigationController(rootViewController: loginView)
                
                //モーダル画面をフルスクリーンに設定し遷移
                loginViewController.modalPresentationStyle = .fullScreen
                present(loginViewController, animated: true, completion: nil)
            } else {
                break
            }
        default:
            //tabbarの非選択色の設定
            tabBar.unselectedItemTintColor =  UIColor.gray
        }
    }
}
