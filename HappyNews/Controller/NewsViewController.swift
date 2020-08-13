//
//  ViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import SegementSlide

class NewsViewController: SegementSlideDefaultViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        defaultSelectedIndex = 0
    }
    
    //ニュースタブのコード
    override var titlesInSwitcher: [String] {
        
        return ["トップ","エンタメ","スポーツ","ビジネス","IT・化学","経済","政治","地域","国際"]
    }

    //コントローラーを返すメソッド
//    override func segementSlideContentScrollView(at index: Int) -> SegementSlideContentScrollViewDelegate? {
//
//        switch index {
//        case 0:
//            <#code#>
//        default:
//            <#code#>
//        }
//    }
}

