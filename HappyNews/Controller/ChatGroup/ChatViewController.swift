//
//  ChatViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/04.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // NavigationBarの呼び出し
        setChatNavigationBar()
    }
    

    // MARK: - Navigation
    // ニュースページのNavigationBarを設定
    func setChatNavigationBar() {
        
        // NavigationBarのタイトルとその色とフォント
        navigationItem.title = "チャットページ"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .semibold)]
        
        // NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        // 一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        // NavigationBarの下線を削除
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
