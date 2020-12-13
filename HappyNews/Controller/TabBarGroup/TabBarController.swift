//
//  TabBarViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import Lottie

class TabBarController: UITabBarController {
    
    //インスタンスの作成
    var loadingAnimationView = AnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //起動時のitemの色
        UITabBar.appearance().tintColor = UIColor(hex: "00AECC")
        
        //tabbarの色を変更
        tabBar.barTintColor = UIColor(hex: "ffffff")
    
        //tabbar背景の透過
        UITabBar.appearance().backgroundImage = UIImage()
        
        //アニメーションとラベルの呼び出し
        addAnimationView()
        addLabel()
    }
    
    //アニメーションの準備
    func addAnimationView() {
        
        //アニメーションファイルの指定
        loadingAnimationView = AnimationView(name: "loading")
        
        //アニメーションの位置指定（画面中央）
        loadingAnimationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        //アニメーションのアスペクト比を指定＆ループで開始
        loadingAnimationView.contentMode = .scaleAspectFit
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.play()
        
        //アニメーションの背景色を設定し、Tab & Nav を隠す
        loadingAnimationView.backgroundColor = UIColor.white
        
        //ViewControllerに配置
        view.addSubview(loadingAnimationView)
    }
    
    //loading中のラベルの準備
    func addLabel() {
        
        //ラベルの生成
        let loadingTextLabel = UILabel()
        
        //位置指定
        loadingTextLabel.frame = CGRect(x: 0, y: 200, width: view.frame.size.width, height: view.frame.size.height)
        
        //テキストとカラーとフォントの設定
        loadingTextLabel.text = "Happyなニュースを解析中..."
        loadingTextLabel.textColor = UIColor.black
        loadingTextLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        //横揃えの設定
        loadingTextLabel.textAlignment = .center
        
        //ViewControllerに配置
        view.addSubview(loadingTextLabel)
    }
    
    //tabbarをタップした場合のアクション
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "ニュース":
            tabBar.tintColor = UIColor(hex: "00AECC")
        case "天気":
            tabBar.tintColor = UIColor(hex: "00AECC")
        case "アカウント":
            tabBar.tintColor = UIColor(hex: "00AECC")
        default:
            //tabbarの非選択色の設定
            tabBar.unselectedItemTintColor =  UIColor.gray
        }
    }
}
