//
//  UIViewController+LoadingAnimation.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/12/15.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import Foundation
import UIKit
import Lottie

extension UIViewController {
    
    // MARK: - LoadingAnimation
    //loadingアニメーションの準備
    func addloadingAnimationView() {
        
        //インスタンスの作成
        var loadingAnimationView = AnimationView()
        
        //アニメーションファイルの指定
        loadingAnimationView = AnimationView(name: "loading")
        
        //アニメーションの位置指定（画面中央）
        loadingAnimationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        //アニメーションのアスペクト比を指定＆ループで開始
        loadingAnimationView.contentMode = .scaleAspectFit
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.play()
        
        //アニメーションの背景色を設定し、'Tab & Nav'を隠す
        loadingAnimationView.backgroundColor = UIColor.white
        
        //アニメーションを最前面に表示
        loadingAnimationView.layer.zPosition = 10
        
        //ViewControllerに配置
        view.addSubview(loadingAnimationView)
    }
    
    //loading中のラベルの準備
    func addloadingLabel() {

        let loadingTextLabel = UILabel()

        //位置指定
        loadingTextLabel.frame = CGRect(x: 0, y: 200, width: view.frame.size.width, height: view.frame.size.height)

        //テキストとカラーとフォントの設定
        loadingTextLabel.text = "Happyなニュースを解析中..."
        loadingTextLabel.textColor = UIColor.black
        loadingTextLabel.font = UIFont.boldSystemFont(ofSize: 24)

        //横揃えの設定
        loadingTextLabel.textAlignment = .center

        //ローディング中のラベルを最前面に表示
        loadingTextLabel.layer.zPosition = 10

        //ViewControllerに配置
        view.addSubview(loadingTextLabel)
    }
}
