//
//  SearchViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    //中央のラベルを設定
    var centerLabel: UILabel = {
        
        //UILabelのインスタンスを作成
        var label = UILabel()
        
        //labelのテキストとフォントとテキストカラー設定
        label.text = "アカウントページ"
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.textColor = UIColor.black
        
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        //UIviewのインスタンス作成(view)
        view = UIView()
        
        //viewの背景を設定
        view.backgroundColor = .white
        
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(centerLabel)
        NSLayoutConstraint.activate([
            centerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
