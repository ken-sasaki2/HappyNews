//
//  WebViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import WebKit

// タップしたニュースのURLを取得してWebViewを表示する
class WebViewController: UIViewController, WKUIDelegate {

    
    // MARK: - Property
    // WKwebViewのインスタンス作成
    var webView = WKWebView()
    
    // NavigatonBarのボタンのインスタンス
    var closeButton: UIBarButtonItem?
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBarの呼び出し
        webViewNavigationBar()
        
        // WebViewのサイズを設定しviewに反映
        webView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(webView)
        
        // openWebViewの呼び出し
        openWebView()
        
        // スワイプで戻るを有効
        webView.allowsBackForwardNavigationGestures = true
    }
    
    
    // MARK: - Navigation
    // WebViewのNavigationBarの設定
    func webViewNavigationBar() {
        
        // NavigationBarの下からViewが始まる
        self.navigationController?.navigationBar.isTranslucent = false
        
        // NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "f4f8fa")
            
        // NavigationBarのボタン設定
        closeButton = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(tapCloseButton(_:)))
        
        // ボタン反映（右）
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    
    // MARK: - TapCloseButton
    // closeButtonをタップしたときのアクション
    @objc func tapCloseButton(_ sender: UIBarButtonItem) {
        
        // WebViewを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - OpenWebView
    func openWebView() {
        
        //  newsString = ニュースをタップしたときに保存したURL
        let newsString = UserDefault.newsString
        
        // newsStringをURL型に変換
        let newsURL = URL(string: newsString as! String)
        
        // newsURLをURLRequest型に変換
        let tapCellRequest = URLRequest(url: newsURL!)
        
        //WebViewをロード（開く）
        webView.load(tapCellRequest)
    }
}
