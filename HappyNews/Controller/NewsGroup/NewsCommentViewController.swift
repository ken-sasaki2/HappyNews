//
//  NewsCommentViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/20.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit


// ニュースへのコメントを扱うクラス
class NewsCommentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // ×ボタンをタップすると呼ばれる
    @IBAction func tapCloseNewsCommentButton(_ sender: Any) {
        
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
}
