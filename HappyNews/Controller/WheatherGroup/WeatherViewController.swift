//
//  WeatherViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view = UIView()
        
        view.backgroundColor = .white
        
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(centerLabel)
        NSLayoutConstraint.activate([
            centerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
