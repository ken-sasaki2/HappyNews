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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //webViewのサイズを決める
        webView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        //viewに反映
        view.addSubview(webView)
        
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
