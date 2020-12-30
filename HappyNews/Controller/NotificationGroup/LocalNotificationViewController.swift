//
//  LocalNotificationViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/12/30.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LocalNotificationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ユーザー情報の確認
        print(Auth.auth().currentUser?.uid)
        print(Auth.auth().currentUser?.displayName)
        
        //UIviewのインスタンス作成(view)
        view = UIView()

        //viewの背景を設定
        view.backgroundColor = UIColor.white
        
        let sampleButton = UIButton()
        
        sampleButton.backgroundColor = UIColor.red
        sampleButton.setTitle("ローカル通知発火", for: UIControl.State.normal)
        sampleButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        sampleButton.frame.size = CGSize(width: 200, height: 100)
        
        sampleButton.addTarget(self, action: #selector(localNotification), for: .touchUpInside)
        view.addSubview(sampleButton)
    }
    
    //ローカルPush通知の作成
    @objc func localNotification() {
        
        //ローカルPush通知のインスタンス作成
        let content = UNMutableNotificationContent()
        
        //通知内容の設定
        content.title    = "【お知らせ】HappyNews更新"
        content.subtitle = "新たなニュースを取得できます"
        content.sound    = .default
        
        //通知の表示
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
