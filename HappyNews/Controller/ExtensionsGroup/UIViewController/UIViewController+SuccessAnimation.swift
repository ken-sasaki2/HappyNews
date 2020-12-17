//
//  UIViewController+SuccessAnimation.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/12/15.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import Foundation
import UIKit
import Lottie

extension UIViewController {
    
    // MARK: - SuccessAnimation
    //successアニメーションの準備
    func addSuccessAnimationView() {
        
        //インスタンスの作成
        var successAnimationView = AnimationView()

        //アニメーションファイルの指定
        successAnimationView = AnimationView(name: "success")

        //アニメーションの位置指定（画面中央）
        successAnimationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)

        //アニメーションのアスペクト比を指定＆ループで開始
        successAnimationView.contentMode = .scaleAspectFit
        successAnimationView.pause()
        successAnimationView.play()

        //アニメーションの背景色を設定し、'Tab & Nav'を隠す
        successAnimationView.backgroundColor = UIColor.white
        
        //アニメーションを最前面に表示
        successAnimationView.layer.zPosition = 11
        
        //ViewControllerに配置
        view.addSubview(successAnimationView)
    }
    
    //success後のラベルの準備
    func addSuccessLabel() {

        let successTextLabel = UILabel()

        //位置指定
        successTextLabel.frame = CGRect(x: 0, y: 200, width: view.frame.size.width, height: view.frame.size.height)

        //テキストとカラーとフォントの設定
        successTextLabel.text = "ページを移動します..."
        successTextLabel.textColor = UIColor.black
        successTextLabel.font = UIFont.boldSystemFont(ofSize: 24)

        //横揃えの設定
        successTextLabel.textAlignment = .center

        //success後のラベルを最前面に表示
        successTextLabel.layer.zPosition = 11

        //ViewControllerに配置
        view.addSubview(successTextLabel)
    }
}
