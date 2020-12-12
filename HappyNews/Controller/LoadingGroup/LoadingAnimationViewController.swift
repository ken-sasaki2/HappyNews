//
//  LoadingAnimationViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/11/04.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import Lottie

class LoadingAnimationViewController: UIViewController, AnalysisCompleteProtocol {

    //AnimationViewの宣言
    var loadingAnimationView = AnimationView()
    
    //インスタンス作成
    var topNewsController = TopNewsTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //アニメーションとラベルの呼び出し
        addAnimationView()
        addLabel()
        
        //TopNewsの感情分析を開始
        topNewsController.viewDidLoad()
        
        //TopNewsのプロトコルを委託
        topNewsController.analysisCompleteProtocol = self
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
    
    //TopNewsControllerと通信
    func analysisComplete(completeSign: String) {
        
        let completeString = completeSign
        
        if completeString == "LoadingComplete" {
            
            //0.5秒遅れて遷移
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "LoadingComplete", sender: nil)
            }
        }
    }
}
