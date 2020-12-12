//
//  SuccessAnimationViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/12/11.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import Lottie

class SuccessAnimationViewController: UIViewController {
    
    //AnimationViewの宣言
    var successAnimationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //0.5秒遅れて表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            //アニメーションとラベルの呼び出し
            self.addAnimationView()
            self.addLabel()
        }
        
        //1.5秒遅れて遷移
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.performSegue(withIdentifier: "success", sender: nil)
        }
    }
    
    //アニメーションの準備
    func addAnimationView() {
        
        //アニメーションファイルの指定
        successAnimationView = AnimationView(name: "success")
        
        //アニメーションの位置指定（画面中央）
        successAnimationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        //アニメーションのアスペクト比を指定＆ループで開始
        successAnimationView.contentMode = .scaleAspectFit
        successAnimationView.pause()
        successAnimationView.play()
        
        //ViewControllerに配置
        view.addSubview(successAnimationView)
    }
    
    //loading中のラベルの準備
    func addLabel() {
        
        //ラベルの生成
        let successTextLabel = UILabel()
        
        //位置指定
        successTextLabel.frame = CGRect(x: 0, y: 200, width: view.frame.size.width, height: view.frame.size.height)
        
        //テキストとカラーとフォントの設定
        successTextLabel.text = "ページを移動します..."
        successTextLabel.textColor = UIColor.black
        successTextLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        //横揃えの設定
        successTextLabel.textAlignment = .center
        
        //ViewControllerに配置
        view.addSubview(successTextLabel)
    }
}
