//
//  TermsOfUseViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/24.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit
import WebKit

// ▼関係するclass
// LoginViewController
// SaveUserInformationViewController

// 利用規約を表示するクラス
class TermsOfUseViewController: UIViewController {
    
    // MARK: - Property
    // WKwebViewのインスタンス作成
    var webView = WKWebView()

    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        // WebViewのサイズを設定しviewに反映
        webView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(webView)

        // newsString = ニュースをタップしたときに保存したURL
        let termsOfUseString = UserDefault.standard.object(forKey: "termsOfUseLink")
                
        // newsStringをURL型に変換
        let termsOfUseURL = URL(string: termsOfUseString as! String)
        
        // newsURLをURLRequest型に変換
        let termsOfUseRequest = URLRequest(url: termsOfUseURL!)
        
        //WebViewをロード（開く）
        webView.load(termsOfUseRequest)
    }
}
