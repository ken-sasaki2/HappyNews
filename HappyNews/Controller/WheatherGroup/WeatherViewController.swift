//
//  WeatherViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NavigationBarの呼び出し
        setWeatherNavigationBar()
        
        view = UIView()
        
        view.backgroundColor = .white
        
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(centerLabel)
        NSLayoutConstraint.activate([
            centerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    //天気予報ページのNavigationBar設定
    func setWeatherNavigationBar() {
        
        //NavigationBarのtitleとその色とフォント
        navigationItem.title = "天気予報"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0)]
        
        //NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "ff4500")
        
        //一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        //NavigationBarの下線を消す
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    //中央のラベルを設定
    var centerLabel: UILabel = {
        
        //UILabelのインスタンスを作成
        var label = UILabel()
        
        //labelのテキストとフォントとテキストカラー設定
        label.text = "天気予報ページ"
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.textColor = UIColor.black
        
        return label
    }()
}
