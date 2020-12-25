//
//  WebViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController,WKUIDelegate {

    //WKwebViewのインスタンス作成
    var webView = WKWebView()
    
    //NavigatonBarのボタンのインスタンス
    var closeButton: UIBarButtonItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NavigationBarの呼び出し
        webViewNavigationBar()
        
        //webViewのサイズ設定
        webView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        //viewに反映
        view.addSubview(webView)
        
        //webViewの表示
        openWebView()
        
        //スワイプで戻るを有効
        webView.allowsBackForwardNavigationGestures = true
    }

    //WebViewのNavigationBar設定
    func webViewNavigationBar() {
        
        //NavigationBarの下からViewが始まる
        self.navigationController?.navigationBar.isTranslucent = false
        
        //NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor.white
            
        //NavigationBarのボタン設定
        closeButton = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(tapCloseButton(_:)))
        
        //ボタン反映（右）
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    //closeボタンをタップしたときのアクション
    @objc func tapCloseButton(_ sender: UIBarButtonItem) {
        
        //WebViewを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    func openWebView() {
        
        //TopNewsから受け取ったキー値urlで保存されている値をurlStringへ代入
        let urlString = UserDefaults.standard.object(forKey: "url")
        
        //TopNewsから受け取った文字列url(urlString)をURL型にキャッシュしてurlに代入
        let url = URL(string: urlString as! String)
        
        //TopNewsから受け取ったurlをURLRequest型にしてrequestに代入
        let request = URLRequest(url: url!)
        
        //webViewをロード（開く）
        webView.load(request)
    }
}
