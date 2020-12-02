//
//  LottieViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/11/04.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import Lottie

class LottieViewController: UIViewController {
    
    //AnimationViewの宣言
    var animationView = AnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()

        //アニメーションの呼び出し
        addAnimationView()
        
        //ラベルの呼び出し
        addLabel()
    }
    
    //アニメーションの準備
    func addAnimationView() {
        
        //アニメーションファイルの指定
        animationView = AnimationView(name: "analysis")
        
        //アニメーションの位置指定（画面中央）
        animationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        //アニメーションのアスペクト比を指定＆ループで開始
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
        //ViewControllerに配置
        view.addSubview(animationView)
    }
    
    //loading中のラベルの準備
    func addLabel() {
        
        //ラベルの生成
        let textLabel = UILabel()
        
        //位置指定
        textLabel.frame = CGRect(x: 0, y: 200, width: view.frame.size.width, height: view.frame.size.height)
        
        //テキストとカラーとフォントの設定
        textLabel.text = "Happyなニュースを解析中"
        textLabel.textColor = UIColor.black
        textLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        //横揃えの設定
        textLabel.textAlignment = .center
        
        //ViewControllerに配置
        view.addSubview(textLabel)
    }
}
