//
//  NextViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/11/30.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class NextViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NavigationBarの呼び出し
        setAccountNavigationBar()
        
        //ログアウトボタンの呼び出し
        createLogOutButton()
    }
    
    func createLogOutButton() {
        
        let logOutButton = UIButton()
        
        //'Autosizing'を'AutoLayout' に変換
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        //ログアウトボタンのタイトルの色とサイズと背景色を設定
        logOutButton.setTitle("ログアウト", for: UIControl.State.normal)
        logOutButton.setTitleColor(UIColor.white, for: .normal)
        logOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 19)
        logOutButton.backgroundColor = UIColor.black
        
        //ログアウトボタンの角を丸める
        logOutButton.layer.cornerRadius = 5.0
        
        //ログアウトボタンがタップされた時の挙動を記述してviewに反映
        logOutButton.addTarget(self, action: #selector(tapLogOutButton), for: .touchUpInside)
        view.addSubview(logOutButton)
        
        //ログアウトボタンのサイズを設定
        logOutButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        logOutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        //全機種で画面中央に配置
        NSLayoutConstraint.activate([logOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
    
    //ログアウトボタンがタップされると呼ばれる
    @objc func tapLogOutButton() {
        print("tap")
        
        //ここでログアウト
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        //サインアウトすると元の画面へ遷移
        self.navigationController?.popViewController(animated: true)
    }
    
    //アカウントページのNavigationBar設定
    func setAccountNavigationBar() {
        
        //NavigationBarのtitleとその色とフォント
        navigationItem.title = "アカウントメニュー"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19.0)]
        
        //NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "ffa500")
        
        //一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        //NavigationBarの下線を消す
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        //ログイン後の'back'ボタンを削除
        self.navigationItem.hidesBackButton = true
    }

}
